import argparse
import json
import sys
from collections import defaultdict
from pathlib import Path


def parse_args():
    parser = argparse.ArgumentParser(
        description="Genera inventario Ansible desde outputs de Terragrunt (conexión vía SSM)"
    )
    parser.add_argument("--output", required=True, help="Archivo de salida hosts.ini")
    parser.add_argument(
        "--region",
        default=None,
        help="Región AWS para la conexión SSM (si no se pasa, usa AWS_DEFAULT_REGION del entorno)",
    )
    parser.add_argument(
        "--bucket-name",
        default=None,
        help="Bucket S3 usado por el plugin aws_ssm para transferencia de archivos (opcional)",
    )
    return parser.parse_args()


def build_ssm_host(name, instance, region, bucket_name):
    instance_id = instance["id"]

    fields = [
        f"ansible_connection=aws_ssm",
        f"ansible_aws_ssm_instance_id={instance_id}",
        f"ansible_host={instance_id}",
        f"ansible_user=ec2-user",
    ]

    if region:
        fields.append(f"ansible_aws_ssm_region={region}")

    if bucket_name:
        fields.append(f"ansible_aws_ssm_bucket_name={bucket_name}")

    return f"{name} " + " ".join(fields)


def main():
    args = parse_args()
    output_path = Path(args.output)

    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    groups = defaultdict(list)

    for name, instance in data.items():
        tags = instance.get("tags", {})
        ansible_group = tags.get("AnsibleGroup")

        if not ansible_group:
            continue

        host_line = build_ssm_host(name, instance, args.region, args.bucket_name)
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