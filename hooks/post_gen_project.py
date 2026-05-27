import os
import shutil

project_name = "{{cookiecutter.project_name}}"
environments = [e.strip() for e in "{{cookiecutter.environments}}".split(",")]

tf_dir = os.path.join("tf", project_name)
templates_dir = os.path.join(tf_dir, "_templates")
environments_dir = os.path.join(tf_dir, "environments")
shared_dir = os.path.join(tf_dir, "shared")

for env in environments:
    for module in ["compute", "rds"]:
        src = os.path.join(templates_dir, module)
        dst = os.path.join(environments_dir, env, module)
        if os.path.isdir(src):
            shutil.copytree(src, dst)
    print(f"[+] Ambiente '{env}' generado")

shared_templates = os.path.join(templates_dir, "shared")
if os.path.isdir(shared_templates):
    shutil.copytree(shared_templates, shared_dir, dirs_exist_ok=True)
    print(f"[+] Shared inputs generados")

shutil.rmtree(templates_dir)
print(f"[+] _templates eliminado")
print(f"\n✓ Proyecto '{project_name}' generado con ambientes: {', '.join(environments)}")