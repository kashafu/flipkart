import boto3
from flask import Flask, render_template, jsonify
from flask_cors import cross_origin

app = Flask(__name__)
lambda_client = boto3.client('lambda')


@cross_origin()
@app.route("/", methods=["GET", "POST"])
def home_api():
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'text/html',
        },
        'body': render_template('index.html')
    }


def lamda_homepage(event, context):
    if event['httpMethod'] == 'GET' or event['httpMethod'] == 'POST':
        return home_api()
