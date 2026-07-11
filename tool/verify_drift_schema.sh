#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

dart run drift_dev schema dump \
  lib/shared/persistence/local_database.dart \
  "$tmp_dir/schema"
diff -u \
  drift_schemas/drift_schema_v6.json \
  "$tmp_dir/schema/drift_schema_v6.json"

dart run drift_dev schema generate --data-classes --companions \
  drift_schemas/ "$tmp_dir/generated/"
diff -ru test/generated_migrations "$tmp_dir/generated"

dart run drift_dev schema steps \
  drift_schemas/ "$tmp_dir/schema_versions.g.dart"
diff -u \
  lib/shared/persistence/schema_versions.g.dart \
  "$tmp_dir/schema_versions.g.dart"

echo "Drift schema snapshots and migration helpers are reproducible."
