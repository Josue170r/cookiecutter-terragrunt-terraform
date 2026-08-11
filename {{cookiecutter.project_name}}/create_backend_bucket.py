#!/usr/bin/env python3
"""
Crea el bucket S3 para el backend de Terraform si no existe.
Uso: python3 create_backend_bucket.py <environment>

El bucket se crea con la estructura: {{cookiecutter.state_bucket}}-<environment>
Usa el perfil AWS definido en BACKEND_AWS_PROFILE.
"""
import sys
import os

try:
    import boto3
    from botocore.exceptions import ClientError
except ImportError:
    print("Error: boto3 no está instalado. Ejecuta: pip install boto3")
    sys.exit(1)


STATE_BUCKET_PREFIX = "{{cookiecutter.state_bucket}}"


def create_backend_bucket(environment: str) -> None:
    profile = os.environ.get("BACKEND_AWS_PROFILE")
    region = os.environ.get("AWS_DEFAULT_REGION", "mx-central-1")

    if not profile:
        print("Error: BACKEND_AWS_PROFILE no está definido.")
        sys.exit(1)

    bucket_name = f"{STATE_BUCKET_PREFIX}-{environment}"

    session = boto3.Session(profile_name=profile, region_name=region)
    s3 = session.client("s3")

    try:
        s3.head_bucket(Bucket=bucket_name)
        print(f"Bucket '{bucket_name}' ya existe.")
        return
    except ClientError as e:
        error_code = int(e.response["Error"]["Code"])
        if error_code == 404:
            pass
        elif error_code == 403:
            print(f"✗ Sin permisos para verificar el bucket '{bucket_name}'.")
            sys.exit(1)
        else:
            raise

    print(f"  Creando bucket '{bucket_name}' en región '{region}'...")

    create_params = {
        "Bucket": bucket_name,
        "CreateBucketConfiguration": {"LocationConstraint": region},
    }
    s3.create_bucket(**create_params)

    # Habilitar versionamiento
    s3.put_bucket_versioning(
        Bucket=bucket_name,
        VersioningConfiguration={"Status": "Enabled"},
    )

    # Habilitar cifrado por defecto
    s3.put_bucket_encryption(
        Bucket=bucket_name,
        ServerSideEncryptionConfiguration={
            "Rules": [
                {
                    "ApplyServerSideEncryptionByDefault": {
                        "SSEAlgorithm": "AES256"
                    },
                    "BucketKeyEnabled": True,
                }
            ]
        },
    )

    # Bloquear acceso público
    s3.put_public_access_block(
        Bucket=bucket_name,
        PublicAccessBlockConfiguration={
            "BlockPublicAcls": True,
            "IgnorePublicAcls": True,
            "BlockPublicPolicy": True,
            "RestrictPublicBuckets": True,
        },
    )

    print(f"Bucket '{bucket_name}' creado exitosamente.")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Uso: {sys.argv[0]} <environment>")
        print(f"  Ejemplo: {sys.argv[0]} dev")
        sys.exit(1)

    env = sys.argv[1]
    create_backend_bucket(env)
