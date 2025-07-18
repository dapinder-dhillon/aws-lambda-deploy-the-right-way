import unittest

from lambda_src.create_s3_presigned_url import lambda_handler, generate_presigned_url, post_to_httpbin


class TestS3PreSignedURL(unittest.TestCase):
    TEST_BUCKET = "sample-bucket"
    TEST_OBJECT_KEY = "sample.csv"


    def test_lambda_handler(self):
        """Test the full Lambda function with real S3 and httpbin call."""
        event = {
            "Records": [
                {
                    "s3": {
                        "bucket": {"name": self.TEST_BUCKET},
                        "object": {"key": self.TEST_OBJECT_KEY}
                    }
                }
            ]
        }

        result = lambda_handler(event, context={})
        self.assertEqual(result['statusCode'], 200)
        self.assertIn("Lambda executed successfully", result['body'])

    def test_generate_presigned_url(self):
        """Test generating a pre-signed S3 URL."""
        url = generate_presigned_url(self.TEST_BUCKET, self.TEST_OBJECT_KEY)
        self.assertIsNotNone(url)
        self.assertTrue(url.startswith("https://"))

    def test_httpbin_request(self):
        """Test making a real HTTP request to httpbin.org."""
        url = generate_presigned_url(self.TEST_BUCKET, self.TEST_OBJECT_KEY)
        response = post_to_httpbin(url)

        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn("url", data["args"])


if __name__ == "__main__":
    unittest.main()
