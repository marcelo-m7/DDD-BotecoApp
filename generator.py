import os
import sys
import yaml
from jinja2 import Environment, FileSystemLoader, TemplateNotFound
from yaml import YAMLError

BASE = os.path.dirname(__file__)
TEMPLATE_DIR = os.path.join(BASE, 'templates')

env = Environment(loader=FileSystemLoader(TEMPLATE_DIR))


def load_domain(path: str) -> dict:
    domain = {
        'enums': {},
        'entities': {},
        'types': {},
        'metadata': {},
        'targets': {},
    }
    found = False

    for root, _, files in os.walk(path):
        for fn in files:
            if not fn.endswith('.yaml'):
                continue
            file_path = os.path.join(root, fn)
            try:
                with open(file_path, 'r') as fh:
                    content = yaml.safe_load(fh)
            except YAMLError as exc:
                raise RuntimeError(f"Failed to parse YAML file {file_path}: {exc}") from exc

            if not content or 'botecopro_domain' not in content:
                continue

            found = True
            domain_data = content.get('botecopro_domain')
            if not isinstance(domain_data, dict):
                raise RuntimeError(f"'botecopro_domain' in {file_path} must be a mapping")

            for section in ('enums', 'entities', 'types'):
                domain[section].update(domain_data.get(section, {}) or {})

            domain['metadata'].update(domain_data.get('metadata', {}) or {})
            domain['targets'].update(domain_data.get('targets', {}) or {})

    if not found:
        raise RuntimeError(f"No botecopro_domain entries found under {path}")
    if not domain['entities']:
        raise RuntimeError("No entities defined in botecopro_domain schemas")

    return domain


def render_template(name: str, ctx: dict) -> str:
    try:
        template = env.get_template(name)
    except TemplateNotFound as exc:
        raise RuntimeError(f"Template '{name}' not found in templates directory") from exc
    return template.render(ctx)


def build_entity_contexts(domain: dict) -> list:
    default_schema = domain.get('metadata', {}).get('default_schema', 'main')
    contexts = []
    for entity_name, entity_data in domain.get('entities', {}).items():
        storage = entity_data.get('storage', {}) or {}
        attributes = entity_data.get('attributes', {}) or {}
        contexts.append({
            'entity': entity_name,
            'table': storage.get('table', entity_name.lower()),
            'schema': storage.get('schema', default_schema),
            'attributes': attributes,
            'indexes': entity_data.get('indexes', []),
            'storage': storage,
            'types': domain.get('types', {}),
            'enums': domain.get('enums', {}),
        })
    return contexts


def main() -> None:
    schema_dir = os.path.join(BASE, 'db-meta', 'schemas')
    domain = load_domain(schema_dir)
    entities = build_entity_contexts(domain)

    out_dir = os.path.join(BASE, 'generated')
    python_out = os.path.join(out_dir, 'python')
    sql_out = os.path.join(out_dir, 'sql')
    os.makedirs(python_out, exist_ok=True)
    os.makedirs(sql_out, exist_ok=True)

    for entity in entities:
        ctx = {'entity': entity, 'enums': domain.get('enums', {}), 'types': domain.get('types', {})}

        python_rendered = render_template('python_sqlmodel.j2', ctx)
        with open(os.path.join(python_out, f"{entity['entity'].lower()}_model.py"), 'w') as fh:
            fh.write(python_rendered)

        sql_rendered = render_template('sqlite_model.j2', ctx)
        with open(os.path.join(sql_out, f"{entity['entity'].lower()}_table.sql"), 'w') as fh:
            fh.write(sql_rendered)

    print('Generated', len(entities), 'models')


if __name__ == '__main__':
    try:
        main()
    except Exception as exc:
        print(f"Error: {exc}")
        sys.exit(1)
