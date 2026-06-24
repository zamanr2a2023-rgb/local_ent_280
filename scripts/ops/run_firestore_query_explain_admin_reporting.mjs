#!/usr/bin/env node

import { execSync } from "node:child_process";

const projectId = process.env.FIRESTORE_PROJECT_ID || "local-transport-482015";
const databaseId = process.env.FIRESTORE_DATABASE_ID || "(default)";

function getAccessToken() {
  return execSync("gcloud auth print-access-token", {
    encoding: "utf8",
    stdio: ["ignore", "pipe", "pipe"],
  }).trim();
}

async function runQueryExplain(accessToken, payload) {
  const endpoint =
    `https://firestore.googleapis.com/v1/projects/${projectId}` +
    `/databases/${databaseId}/documents:runQuery`;
  const response = await fetch(endpoint, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      ...payload,
      explainOptions: { analyze: true },
    }),
  });
  if (!response.ok) {
    const body = await response.text();
    throw new Error(`runQuery failed (${response.status}): ${body}`);
  }
  return response.json();
}

function toSummary(name, responsePayload) {
  const entries = Array.isArray(responsePayload) ? responsePayload : [];
  const explained = entries.find((entry) => entry.explainMetrics != null);
  if (!explained?.explainMetrics) {
    return {
      name,
      index: "N/A",
      resultsReturned: 0,
      indexEntriesScanned: 0,
      documentsScanned: 0,
      readOperations: 0,
      executionDuration: "N/A",
    };
  }
  const metrics = explained.explainMetrics;
  const executionStats = metrics.executionStats ?? {};
  const debugStats = executionStats.debugStats ?? {};
  const indexesUsed = metrics.planSummary?.indexesUsed ?? [];
  return {
    name,
    index: indexesUsed.map((index) => index.properties).join(" | "),
    resultsReturned: Number.parseInt(executionStats.resultsReturned ?? "0", 10),
    indexEntriesScanned: Number.parseInt(
      debugStats.index_entries_scanned ?? "0",
      10,
    ),
    documentsScanned: Number.parseInt(debugStats.documents_scanned ?? "0", 10),
    readOperations: Number.parseInt(executionStats.readOperations ?? "0", 10),
    executionDuration: executionStats.executionDuration ?? "N/A",
  };
}

const queries = [
  {
    name: "reports.trips_by_started_at",
    payload: {
      structuredQuery: {
        from: [{ collectionId: "trips" }],
        where: {
          compositeFilter: {
            op: "AND",
            filters: [
              {
                fieldFilter: {
                  field: { fieldPath: "status" },
                  op: "IN",
                  value: {
                    arrayValue: {
                      values: [
                        { stringValue: "COMPLETED" },
                        { stringValue: "CHARGE_APPLIED" },
                      ],
                    },
                  },
                },
              },
              {
                fieldFilter: {
                  field: { fieldPath: "startedAt" },
                  op: "GREATER_THAN_OR_EQUAL",
                  value: { timestampValue: "2025-01-01T00:00:00Z" },
                },
              },
              {
                fieldFilter: {
                  field: { fieldPath: "startedAt" },
                  op: "LESS_THAN",
                  value: { timestampValue: "2027-01-01T00:00:00Z" },
                },
              },
            ],
          },
        },
        orderBy: [
          {
            field: { fieldPath: "startedAt" },
            direction: "ASCENDING",
          },
          {
            field: { fieldPath: "__name__" },
            direction: "ASCENDING",
          },
        ],
        limit: 20,
      },
    },
  },
  {
    name: "reports.trips_by_completed_at",
    payload: {
      structuredQuery: {
        from: [{ collectionId: "trips" }],
        where: {
          compositeFilter: {
            op: "AND",
            filters: [
              {
                fieldFilter: {
                  field: { fieldPath: "status" },
                  op: "IN",
                  value: {
                    arrayValue: {
                      values: [
                        { stringValue: "COMPLETED" },
                        { stringValue: "CHARGE_APPLIED" },
                      ],
                    },
                  },
                },
              },
              {
                fieldFilter: {
                  field: { fieldPath: "completedAt" },
                  op: "GREATER_THAN_OR_EQUAL",
                  value: { timestampValue: "2025-01-01T00:00:00Z" },
                },
              },
              {
                fieldFilter: {
                  field: { fieldPath: "completedAt" },
                  op: "LESS_THAN",
                  value: { timestampValue: "2027-01-01T00:00:00Z" },
                },
              },
            ],
          },
        },
        orderBy: [
          {
            field: { fieldPath: "completedAt" },
            direction: "ASCENDING",
          },
          {
            field: { fieldPath: "__name__" },
            direction: "ASCENDING",
          },
        ],
        limit: 20,
      },
    },
  },
  {
    name: "admin.audit_by_action_admin",
    payload: {
      structuredQuery: {
        from: [{ collectionId: "audit" }],
        where: {
          compositeFilter: {
            op: "AND",
            filters: [
              {
                fieldFilter: {
                  field: { fieldPath: "createdAt" },
                  op: "GREATER_THAN_OR_EQUAL",
                  value: { timestampValue: "2025-01-01T00:00:00Z" },
                },
              },
              {
                fieldFilter: {
                  field: { fieldPath: "createdAt" },
                  op: "LESS_THAN_OR_EQUAL",
                  value: { timestampValue: "2026-12-31T23:59:59Z" },
                },
              },
              {
                fieldFilter: {
                  field: { fieldPath: "actionType" },
                  op: "EQUAL",
                  value: { stringValue: "balance_adjustment" },
                },
              },
              {
                fieldFilter: {
                  field: { fieldPath: "adminId" },
                  op: "EQUAL",
                  value: {
                    stringValue: "tt7O1oo3PoP1R1Oru8EiG9duZ233",
                  },
                },
              },
            ],
          },
        },
        orderBy: [
          {
            field: { fieldPath: "createdAt" },
            direction: "DESCENDING",
          },
        ],
        limit: 20,
      },
    },
  },
];

async function main() {
  const accessToken = getAccessToken();
  const summaries = [];
  for (const query of queries) {
    const responsePayload = await runQueryExplain(accessToken, query.payload);
    summaries.push(toSummary(query.name, responsePayload));
  }
  console.log(
    JSON.stringify(
      {
        projectId,
        databaseId,
        generatedAt: new Date().toISOString(),
        summaries,
      },
      null,
      2,
    ),
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
