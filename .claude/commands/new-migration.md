Implement a new database migration safely, following project conventions.

**TRIGGER when:** adding a new DB table, column, index, constraint, enum, or any other schema change.

Arguments (optional): $ARGUMENTS — brief description of the migration (e.g. "add stripe_customer_id to users")

---

## Steps — complete in this order

### Step 1 — Detect migration framework and conventions

Check which framework this project uses:

```bash
# Check for common migration frameworks
ls migrations/ 2>/dev/null || ls db/migrations/ 2>/dev/null || ls prisma/migrations/ 2>/dev/null || \
ls alembic/versions/ 2>/dev/null || ls flyway/ 2>/dev/null || ls scripts/sql-migrations/ 2>/dev/null
```

Also check `package.json` for Drizzle, Prisma, or other ORM scripts. Check for `alembic.ini` (Python), `flyway.conf` (Java), or `knexfile.js` (Node).

**Framework-specific conventions:**

| Framework | Migration location | Naming convention |
|-----------|-------------------|-------------------|
| Drizzle ORM | `drizzle/` or custom path | Sequential number prefix |
| Prisma | `prisma/migrations/` | Timestamp + description |
| Alembic (Python) | `alembic/versions/` | Hash + description |
| Flyway | `sql/` or `migrations/` | `V{version}__{description}.sql` |
| Raw SQL (custom) | `scripts/sql-migrations/` or similar | Sequential number prefix |
| Knex | `migrations/` | Timestamp + description |

### Step 2 — Determine the next migration number/name

For sequential-numbered projects:
```bash
ls migrations/ | sort | tail -5   # or whichever directory applies
```
Take the highest existing number and increment by 1. Use zero-padded 3-digit format (e.g., `024`) for consistency with existing files.

For timestamp-named projects: use the current date/time.

### Step 3 — Check for an existing Drizzle/ORM schema file

If the project has an ORM schema file (`schema.ts`, `schema.py`, `models.py`, `prisma/schema.prisma`, etc.):
- Read the existing schema to understand column naming conventions (snake_case vs camelCase), UUID usage, timestamp patterns, soft-delete patterns
- Add the new table/column definitions to the schema file alongside the SQL migration

### Step 4 — Write the migration

**Non-negotiable SQL rules (apply to every migration regardless of framework):**

1. **All `CREATE TABLE` statements must use `IF NOT EXISTS`**
   ```sql
   CREATE TABLE IF NOT EXISTS my_table ( ... );
   ```

2. **All `CREATE INDEX` statements must use `IF NOT EXISTS` and be named**
   ```sql
   CREATE INDEX IF NOT EXISTS idx_my_table_column ON my_table (column);
   ```
   Never use anonymous indexes. Named indexes are idempotent and debuggable.

3. **All `ADD COLUMN` statements must use `IF NOT EXISTS` (PostgreSQL 9.6+)**
   ```sql
   ALTER TABLE my_table ADD COLUMN IF NOT EXISTS new_col TEXT;
   ```

4. **Always include a rollback/down migration** (or a comment explaining why rollback is destructive and requires manual intervention)

5. **UUIDs for primary keys** unless the project's existing tables use integer PKs — match what's already there

6. **`created_at` and `updated_at`** on every new table (match existing timestamp patterns)

7. **Foreign key constraints** must reference the exact column type of the parent

### Step 5 — Run the migration (do not skip)

For Drizzle: `npm run db:push` or `npx drizzle-kit push`
For Prisma: `npx prisma migrate dev --name <name>`
For Alembic: `alembic upgrade head`
For Flyway: `flyway migrate`
For raw SQL: `psql $DATABASE_URL -f <migration-file>`

Confirm the migration applied without errors before committing.

### Step 6 — Commit

Commit message format:
```
db: add <description> migration (<number>)

Table/columns added: <list>
Indexes: <list or "none">
Schema file updated: yes/no
```

### Step 7 — Confirm

State: "Migration `<filename>` created and applied. Tables: [list]. Indexes: [list]. Schema file updated: [yes/no]. Migration ran without errors."
