variable "region" {
  default = "us-east-1"
}
variable "accountId" {
  default = "064741436968"
}

resource "aws_api_gateway_rest_api" "home_api" {
  name = "home_api"
}
resource "aws_api_gateway_resource" "home_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.home_api.id
  parent_id   = aws_api_gateway_rest_api.home_api.root_resource_id
  path_part   = "home"
}
resource "aws_api_gateway_method" "home_api_method" {
  rest_api_id   = aws_api_gateway_rest_api.home_api.id
  resource_id   = aws_api_gateway_resource.home_api_resource.id
  http_method   = "GET"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.home_api.id
  resource_id             = aws_api_gateway_resource.home_api_resource.id
  http_method             = aws_api_gateway_method.home_api_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.home_api.invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.home_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${var.accountId}:${aws_api_gateway_rest_api.home_api.id}/*/${aws_api_gateway_method.home_api_method.http_method}${aws_api_gateway_resource.home_api_resource.path}"
}
resource "aws_api_gateway_deployment" "home_api" {
  rest_api_id = aws_api_gateway_rest_api.home_api.id
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.home_api.body))
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_api_gateway_method.home_api_method, aws_api_gateway_integration.integration]
}
resource "aws_api_gateway_stage" "home_api" {
  deployment_id = aws_api_gateway_deployment.home_api.id
  rest_api_id   = aws_api_gateway_rest_api.home_api.id
  stage_name    = "dev"
}
