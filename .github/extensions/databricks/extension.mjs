import { joinSession } from "@github/copilot-sdk/extension";
import { readFileSync, readdirSync, statSync } from "node:fs";
import { homedir } from "node:os";
import { join, dirname, relative } from "node:path";
import { fileURLToPath } from "node:url";

// Load credentials from ~/.databricks_auth.env
function loadAuth() {
    try {
        const envFile = readFileSync(join(homedir(), ".databricks_auth.env"), "utf-8");
        const token = envFile.match(/DATABRICKS_TOKEN=(\S+)/)?.[1];
        const host = envFile.match(/DATABRICKS_HOST=(\S+)/)?.[1];
        if (!token || !host) throw new Error("Missing DATABRICKS_TOKEN or DATABRICKS_HOST");
        return { token, host: host.replace(/\/$/, "") };
    } catch (err) {
        throw new Error(`Failed to load ~/.databricks_auth.env: ${err.message}`);
    }
}

const DEFAULT_WAREHOUSE_ID = "0b49b7d78734ad5c"; // CDSI Warehouse
const DEFAULT_CATALOG = "cdsi_eng_phi";
const DEFAULT_SCHEMA = "pdm_base_tables";

// Repo root is two levels up from .github/extensions/databricks/
const REPO_ROOT = join(dirname(fileURLToPath(import.meta.url)), "../../..");
// Local checkout of the pipelines repo (SQL source of truth)
const PIPELINES_REPO = "/gpfs/cdsi_ess/home/limr/ess/repos/pdm_databricks_pipelines";

// ---------------------------------------------------------------------------
// Datasheet index — built once at startup from the repo's markdown files
// ---------------------------------------------------------------------------

function buildDatasheetIndex() {
    const index = []; // { file, title, databricksPath }
    const SKIP_FILES = new Set(["README.md", "template.md", "readme.md"]);
    const SKIP_DIRS = new Set([".git", ".github", "figures", "scripts"]);

    function walk(dir) {
        for (const entry of readdirSync(dir)) {
            if (SKIP_DIRS.has(entry)) continue;
            const full = join(dir, entry);
            const stat = statSync(full);
            if (stat.isDirectory()) {
                walk(full);
            } else if (entry.endsWith(".md") && !SKIP_FILES.has(entry) && !full.includes("/sql/")) {
                try {
                    const text = readFileSync(full, "utf-8");
                    const titleMatch = text.match(/^#\s+(.+)/m);
                    const title = titleMatch ? titleMatch[1].trim() : entry.replace(".md", "");
                    const pathMatch = text.match(/`?(cdsi_prod\.[a-z0-9_.]+)`?/);
                    const databricksPath = pathMatch ? pathMatch[1] : null;
                    index.push({
                        file: relative(REPO_ROOT, full),
                        title,
                        databricksPath,
                    });
                } catch (_) { /* skip unreadable files */ }
            }
        }
    }

    walk(REPO_ROOT);
    return index;
}

function formatDatasheetIndex(index) {
    const lines = ["## Documented Datasets in this Repo\n"];
    lines.push("| Title | Databricks Table | Datasheet |");
    lines.push("|---|---|---|");
    for (const { file, title, databricksPath } of index) {
        lines.push(`| ${title} | ${databricksPath ?? "—"} | ${file} |`);
    }
    return lines.join("\n");
}

// ---------------------------------------------------------------------------
// Pipeline SQL index — maps table names to their SQL source files
// ---------------------------------------------------------------------------

function buildPipelineSqlIndex() {
    const index = []; // { file, tableName }
    try {
        function walk(dir) {
            for (const entry of readdirSync(dir)) {
                const full = join(dir, entry);
                const stat = statSync(full);
                if (stat.isDirectory() && !entry.startsWith(".")) {
                    walk(full);
                } else if (entry.endsWith(".sql")) {
                    try {
                        const content = readFileSync(full, "utf-8");
                        // Match CREATE [OR REPLACE] MATERIALIZED VIEW [IF NOT EXISTS] <name>
                        const tableMatch = content.match(/CREATE\s+(?:OR\s+REPLACE\s+)?(?:STREAMING\s+)?(?:MATERIALIZED\s+VIEW|TABLE)\s+(?:IF\s+NOT\s+EXISTS\s+)?(?:[\w.]+\.)?(\w+)/is);
                        const tableName = tableMatch ? tableMatch[1].toLowerCase() : entry.replace(".sql", "");
                        index.push({ file: relative(PIPELINES_REPO, full), tableName, fullPath: full });
                    } catch (_) {}
                }
            }
        }
        walk(PIPELINES_REPO);
    } catch (_) { /* pipelines repo not accessible */ }
    return index;
}

async function dbRequest(path, method = "GET", body = null) {
    const { token, host } = loadAuth();
    const res = await fetch(`${host}${path}`, {
        method,
        headers: {
            Authorization: `Bearer ${token}`,
            "Content-Type": "application/json",
        },
        ...(body ? { body: JSON.stringify(body) } : {}),
    });
    const text = await res.text();
    if (!res.ok) throw new Error(`Databricks API error ${res.status}: ${text}`);
    return text ? JSON.parse(text) : {};
}

// Execute SQL and poll until complete, return rows as JSON string
async function executeSql(statement, warehouseId, catalog) {
    const payload = {
        statement,
        warehouse_id: warehouseId,
        catalog,
        wait_timeout: "30s",
        on_wait_timeout: "CONTINUE",
        disposition: "INLINE",
        format: "JSON_ARRAY",
    };

    let result = await dbRequest("/api/2.0/sql/statements", "POST", payload);
    const statementId = result.statement_id;

    // Poll if still running
    let attempts = 0;
    while (
        result.status?.state === "PENDING" ||
        result.status?.state === "RUNNING"
    ) {
        if (attempts++ > 30) throw new Error("Query timed out after 5 minutes");
        await new Promise((r) => setTimeout(r, 10_000));
        result = await dbRequest(`/api/2.0/sql/statements/${statementId}`);
    }

    if (result.status?.state === "FAILED") {
        throw new Error(`Query failed: ${result.status.error?.message}`);
    }
    if (result.status?.state === "CANCELED") {
        throw new Error("Query was canceled");
    }

    const schema = result.manifest?.schema?.columns ?? [];
    const rows = result.result?.data_array ?? [];
    const headers = schema.map((c) => c.name);

    if (rows.length === 0) return "Query returned 0 rows.";

    // Format as a markdown table for readability
    const lines = [
        `| ${headers.join(" | ")} |`,
        `| ${headers.map(() => "---").join(" | ")} |`,
        ...rows.map((row) => `| ${row.map((v) => (v === null ? "NULL" : String(v))).join(" | ")} |`),
    ];

    const totalRows = result.manifest?.total_row_count ?? rows.length;
    const note = totalRows > rows.length ? `\n\n_(Showing ${rows.length} of ${totalRows} rows)_` : "";
    return lines.join("\n") + note;
}

const datasheetIndex = buildDatasheetIndex();
const pipelineSqlIndex = buildPipelineSqlIndex();

const session = await joinSession({
    hooks: {
        onSessionStart: async () => {
            await session.log("Databricks extension loaded (CDSI Warehouse · cdsi_eng_phi.pdm_base_tables)");
            return {
                additionalContext:
                    "## Databricks Catalog Guide\n" +
                    "- **Authoritative PHI tables**: `cdsi_eng_phi.pdm_base_tables.*` — always prefer these for queries.\n" +
                    "- **Research PHI copy**: `cdsi_res_phi.pdm_base_tables.*`\n" +
                    "- **De-identified copy**: `cdsi_res_deid.pdm_base_tables.*` (PHI columns stripped)\n" +
                    "- **Legacy tables**: `cdsi_prod.pathology_data_mining.*` — may be referenced in older datasheets.\n" +
                    "- **S3 paths**: join any table with `cdsi_eng_phi.pdm_base_tables.slide_inventory` on `image_id` to get the `path` column (`s3://...`, `source='cBioPortal s3'` or `'ECS2'` or `'On-prem Storage'`).\n" +
                    "- **Pipeline DAG**: slide_inventories → case_breakdown_cleaned → slides_with_diagnosis → impact_matched_slides (runs daily). SQL source: pdm_databricks_pipelines repo.\n\n" +
                    formatDatasheetIndex(datasheetIndex),
            };
        },
    },
    tools: [
        {
            name: "databricks_sql",
            description:
                "Execute a SQL query against the Databricks CDSI Warehouse and return results as a markdown table. " +
                "The default catalog is cdsi_eng_phi (authoritative PHI tables). " +
                "Base tables are in cdsi_eng_phi.pdm_base_tables.*. " +
                "To get slide S3 paths, join with cdsi_eng_phi.pdm_base_tables.slide_inventory on image_id.",
            parameters: {
                type: "object",
                properties: {
                    query: {
                        type: "string",
                        description: "The SQL statement to execute.",
                    },
                    catalog: {
                        type: "string",
                        description: `Catalog context (default: ${DEFAULT_CATALOG}).`,
                    },                    warehouse_id: {
                        type: "string",
                        description: `SQL warehouse ID (default: ${DEFAULT_WAREHOUSE_ID} — CDSI Warehouse).`,
                    },
                },
                required: ["query"],
            },
            handler: async (args) => {
                const warehouseId = args.warehouse_id ?? DEFAULT_WAREHOUSE_ID;
                const catalog = args.catalog ?? DEFAULT_CATALOG;
                try {
                    return await executeSql(args.query, warehouseId, catalog);
                } catch (err) {
                    return { textResultForLlm: err.message, resultType: "failure" };
                }
            },
        },

        {
            name: "databricks_list_schemas",
            description:
                "List all schemas (databases) in a Databricks catalog. Defaults to cdsi_eng_phi.",
            parameters: {
                type: "object",
                properties: {
                    catalog: {
                        type: "string",
                        description: `Catalog name (default: ${DEFAULT_CATALOG}).`,
                    },
                },
            },
            handler: async (args) => {
                const catalog = args.catalog ?? DEFAULT_CATALOG;
                try {
                    return await executeSql(`SHOW SCHEMAS IN ${catalog}`, DEFAULT_WAREHOUSE_ID, catalog);
                } catch (err) {
                    return { textResultForLlm: err.message, resultType: "failure" };
                }
            },
        },

        {
            name: "databricks_list_tables",
            description:
                "List all tables in a Databricks catalog.schema. Defaults to cdsi_eng_phi.pdm_base_tables.",
            parameters: {
                type: "object",
                properties: {
                    catalog: {
                        type: "string",
                        description: `Catalog name (default: ${DEFAULT_CATALOG}).`,
                    },
                    schema: {
                        type: "string",
                        description: "Schema (database) name (default: pdm_base_tables).",
                    },
                },
            },
            handler: async (args) => {
                const catalog = args.catalog ?? DEFAULT_CATALOG;
                const schema = args.schema ?? DEFAULT_SCHEMA;
                try {
                    return await executeSql(
                        `SHOW TABLES IN ${catalog}.${schema}`,
                        DEFAULT_WAREHOUSE_ID,
                        catalog
                    );
                } catch (err) {
                    return { textResultForLlm: err.message, resultType: "failure" };
                }
            },
        },

        {
            name: "databricks_table_schema",
            description:
                "Show the columns, data types, and comments for a Databricks table. " +
                "Pass the fully-qualified name, e.g. cdsi_prod.pathology_data_mining.slides_with_diagnosis.",
            parameters: {
                type: "object",
                properties: {
                    table: {
                        type: "string",
                        description: "Fully-qualified table name (catalog.schema.table).",
                    },
                },
                required: ["table"],
            },
            handler: async (args) => {
                try {
                    return await executeSql(
                        `DESCRIBE TABLE ${args.table}`,
                        DEFAULT_WAREHOUSE_ID,
                        DEFAULT_CATALOG
                    );
                } catch (err) {
                    return { textResultForLlm: err.message, resultType: "failure" };
                }
            },
        },

        {
            name: "databricks_table_sample",
            description:
                "Return the first N rows of a Databricks table to understand its structure and content.",
            parameters: {
                type: "object",
                properties: {
                    table: {
                        type: "string",
                        description: "Fully-qualified table name (catalog.schema.table).",
                    },
                    limit: {
                        type: "number",
                        description: "Number of rows to return (default: 10, max: 100).",
                    },
                },
                required: ["table"],
            },
            handler: async (args) => {
                const limit = Math.min(args.limit ?? 10, 100);
                try {
                    return await executeSql(
                        `SELECT * FROM ${args.table} LIMIT ${limit}`,
                        DEFAULT_WAREHOUSE_ID,
                        DEFAULT_CATALOG
                    );
                } catch (err) {
                    return { textResultForLlm: err.message, resultType: "failure" };
                }
            },
        },

        {
            name: "databricks_datasheet",
            description:
                "Look up the datasheet (schema documentation) for a dataset documented in this repo. " +
                "Returns the full markdown content including field descriptions, data types, notes, and lineage. " +
                "Use this before writing SQL queries to understand a table's fields and any known caveats. " +
                "Search by table name, Databricks path, or topic keyword.",
            parameters: {
                type: "object",
                properties: {
                    query: {
                        type: "string",
                        description:
                            "Table name, Databricks path, or keyword to search for (e.g. 'slides_with_diagnosis', " +
                            "'cdsi_prod.pathology_data_mining.he_slide_embeddings', 'slide embeddings').",
                    },
                },
                required: ["query"],
            },
            handler: async (args) => {
                const q = args.query.toLowerCase();

                // Score each datasheet by relevance to the query
                const scored = datasheetIndex.map((entry) => {
                    let score = 0;
                    const haystack = [
                        entry.title,
                        entry.file,
                        entry.databricksPath ?? "",
                    ].join(" ").toLowerCase();
                    if (haystack.includes(q)) score += 10;
                    // Partial token matching
                    for (const token of q.split(/\W+/).filter(Boolean)) {
                        if (haystack.includes(token)) score += 1;
                    }
                    return { ...entry, score };
                });

                const best = scored.sort((a, b) => b.score - a.score)[0];
                if (!best || best.score === 0) {
                    return `No datasheet found matching "${args.query}". Available datasets:\n\n${formatDatasheetIndex(datasheetIndex)}`;
                }

                try {
                    const content = readFileSync(join(REPO_ROOT, best.file), "utf-8");
                    return `## Datasheet: ${best.title}\n**File:** ${best.file}\n**Databricks table:** ${best.databricksPath ?? "not specified"}\n\n---\n\n${content}`;
                } catch (err) {
                    return { textResultForLlm: `Could not read ${best.file}: ${err.message}`, resultType: "failure" };
                }
            },
        },

        {
            name: "databricks_pipeline_sql",
            description:
                "Return the SQL source that creates a table in the pdm_databricks_pipelines repo. " +
                "This is the canonical, version-controlled definition of how cdsi_eng_phi.pdm_base_tables tables are built. " +
                "Use this to understand exact lineage, joins, and filters before writing queries. " +
                "Search by table name (e.g. 'impact_matched_slides', 'slide_inventory', 'slides_with_diagnosis').",
            parameters: {
                type: "object",
                properties: {
                    table: {
                        type: "string",
                        description: "Table name to look up (e.g. 'impact_matched_slides').",
                    },
                },
                required: ["table"],
            },
            handler: async (args) => {
                if (pipelineSqlIndex.length === 0) {
                    return { textResultForLlm: "pdm_databricks_pipelines repo not accessible at expected path.", resultType: "failure" };
                }
                const q = args.table.toLowerCase().replace(/[^a-z0-9_]/g, "");
                const match = pipelineSqlIndex.find((e) => e.tableName === q)
                    ?? pipelineSqlIndex.find((e) => e.tableName.includes(q) || e.file.toLowerCase().includes(q));
                if (!match) {
                    const available = pipelineSqlIndex.map((e) => `${e.tableName} (${e.file})`).join("\n");
                    return `No SQL found for "${args.table}". Available pipeline SQL files:\n\n${available}`;
                }
                try {
                    const sql = readFileSync(match.fullPath, "utf-8");
                    return `## Pipeline SQL: ${match.tableName}\n**File:** ${match.file}\n\n\`\`\`sql\n${sql}\n\`\`\``;
                } catch (err) {
                    return { textResultForLlm: `Could not read ${match.file}: ${err.message}`, resultType: "failure" };
                }
            },
        },
    ],
});
