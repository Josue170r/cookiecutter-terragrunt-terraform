import os
import shutil

project_name = "{{cookiecutter.project_name}}"
environments = [e.strip() for e in "{{cookiecutter.environments}}".split(",")]

tf_dir = os.path.join("tf", project_name)
templates_dir = os.path.join(tf_dir, "_templates")
environments_dir = os.path.join(tf_dir, "environments")
shared_dir = os.path.join(tf_dir, "shared")

for env in environments:
    for module in ["compute", "rds", "networking"]:
        src = os.path.join(templates_dir, module)
        dst = os.path.join(environments_dir, env, module)
        if os.path.isdir(src):
            shutil.copytree(src, dst)

shared_templates = os.path.join(templates_dir, "shared")
if os.path.isdir(shared_templates):
    shutil.copytree(shared_templates, shared_dir, dirs_exist_ok=True)

shutil.rmtree(templates_dir)

current_dir = os.getcwd()
parent_dir = os.path.dirname(current_dir)

for item in os.listdir(current_dir):
    shutil.move(os.path.join(current_dir, item), os.path.join(parent_dir, item))

os.chdir(parent_dir)
os.rmdir(current_dir)

gitignore_path = os.path.join(parent_dir, ".gitignore")
with open(gitignore_path, "a") as f:
    f.write("\n# Ansible\n")
    f.write("tf/**/ansible/inventory/hosts.ini\n")
    f.write("tf/**/.pems/\n")
os.system("git init")