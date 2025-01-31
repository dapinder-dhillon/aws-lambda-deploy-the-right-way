resource "null_resource" "lambda_dependencies" {
  # the dependencies(zip) should be build each time when either of below file is changed.
  triggers = {
    pyproject_toml_sha256     = filesha256("${path.module}/../../pyproject.toml")
    dockerfile_sha256         = filesha256("${path.module}/../../Dockerfile")
    build_dependencies_sha256 = filesha256("${path.module}/../../build_dependencies_package.sh")
  }
  provisioner "local-exec" {
    command     = format("bash build_dependencies_package.sh")
    working_dir = "${path.module}/../../"
    environment = {
      LAMBDA_PYTHON_DEPENDENCIES_ZIP_NAME = var.lambda_dependencies_zip_name
      TMP_FILE_PATH                       = path.module
    }
  }
}

resource "aws_lambda_layer_version" "lambda_layer" {
  filename = "${path.module}/../../lib_dependencies.zip"
  layer_name = join("-", [
    var.file_distribution_lambda_layer_name,
    var.aws_account_env
  ])
  skip_destroy = true

  compatible_runtimes = [
  var.runtime]
  depends_on = [
  null_resource.lambda_dependencies]

  # the lifecycle is needed since this resource does not get triggered automatically when null_resource is (re)build
  lifecycle {
    replace_triggered_by = [null_resource.lambda_dependencies]
  }
}
