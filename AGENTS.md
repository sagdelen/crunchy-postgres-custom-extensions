# AI Agent Rules

This file contains rules and guidelines for AI agents (GitHub Copilot, Claude, Cursor, etc.) working on this repository.

## Language Rules

**CRITICAL: All code, comments, logs, echo statements, documentation, and any text output MUST be in English only.**

- ❌ NO Turkish, German, or any other non-English language
- ❌ NO mixed language (e.g., English code with Turkish comments)
- ✅ English only for everything

### Examples

```bash
# ❌ WRONG
echo "Kurulum tamamlandı"
echo "Partition'lar siliniyor..."

# ✅ CORRECT
echo "Setup complete"
echo "Deleting partitions..."
```

```sql
-- ❌ WRONG
\echo 'Tablo oluşturuluyor...'

-- ✅ CORRECT
\echo 'Creating table...'
```

## Code Style

- Use clear, descriptive variable names in English
- Write meaningful commit messages in English
- Keep comments concise and in English

## Project Context

This is a Crunchy PostgreSQL custom Docker image project with pg_partman extension for automated partition management testing.
