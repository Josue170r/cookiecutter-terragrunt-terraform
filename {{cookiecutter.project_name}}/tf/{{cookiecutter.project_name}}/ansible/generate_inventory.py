import argparse
import json
import sys
from collections import defaultdict
from pathlib import Path


def parse_args():
    parser = argparse.ArgumentParser(
        description="Genera inventario Ansible desde outputs de Terragrunt"
    )
    parser.add_argument("--pems-dir", required=True, help="Directorio con los .pem")
    parser.add_argument("--output",   required=True, help="Archivo de salida hosts.ini")
    return parser.parse_args()


def build_ssh_host(name, instance, pems_dir):
    return (
        f"{name} "
        f"ansible_host={instance['public_ip']} "
        f"ansible_user=ec2-user "
        f"ansible_ssh_private_key_file={pems_dir / f'{name}.pem'}"
    )


def build_ssm_host(name, instance):
    instance_id = instance["id"]
    proxy = (
        f"aws ssm start-session --target {instance_id} "
        f"--document-name AWS-StartSSHSession --parameters portNumber=22"
    )
    return (
        f"{name} "
        f"ansible_host={instance_id} "
        f"ansible_user=ec2-user "
        f"ansible_ssh_common_args='-o ProxyCommand=\"{proxy}\"'"
    )


def main():
    args  = parse_args()
    pems_dir    = Path(args.pems_dir)
    output_path = Path(args.output)

    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)  # sin output, salir silenciosamente

    groups = defaultdict(list)

    for name, instance in data.items():
        tags          = instance.get("tags", {})
        ansible_group = tags.get("AnsibleGroup")

        if not ansible_group:
            continue  # instancia sin grupo, se omite

        public_ip = instance.get("public_ip")

        if public_ip:
            host_line = build_ssh_host(name, instance, pems_dir)
        else:
            host_line = build_ssm_host(name, instance)

        groups[ansible_group].append(host_line)

    if not groups:
        return

    with open(output_path, "a") as f:
        for group, hosts in groups.items():
            f.write(f"[{group}]\n")
            for host in hosts:
                f.write(f"{host}\n")
            f.write("\n")


if __name__ == "__main__":
    main()