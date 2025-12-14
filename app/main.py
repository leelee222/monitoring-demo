
import json
import logging
import time
import random
import sys
from datetime import datetime
import boto3
from botocore.exceptions import ClientError

LOG_GROUP_NAME = "/devsecops/demo/app"
LOG_STREAM_NAME = "application-stream"
AWS_REGION = "us-east-1"

try:
    cloudwatch_logs = boto3.client('logs', region_name=AWS_REGION)
except Exception as e:
    print(f"Warning: Could not initialize AWS CloudWatch client: {e}")
    print("Logs will only be written to console.")
    cloudwatch_logs = None


class CloudWatchHandler(logging.Handler):
    
    
    def __init__(self, log_group, log_stream, client):
        super().__init__()
        self.log_group = log_group
        self.log_stream = log_stream
        self.client = client
        self.sequence_token = None
        
        if self.client:
            self._ensure_log_stream_exists()
    
    def _ensure_log_stream_exists(self):
        
        try:
            self.client.create_log_stream(
                logGroupName=self.log_group,
                logStreamName=self.log_stream
            )
        except self.client.exceptions.ResourceAlreadyExistsException:
            pass
        except Exception as e:
            print(f"Error creating log stream: {e}")
    
    def emit(self, record):
        
        if not self.client:
            return
        
        try:
            log_event = {
                'timestamp': int(record.created * 1000),
                'message': self.format(record)
            }
            
            kwargs = {
                'logGroupName': self.log_group,
                'logStreamName': self.log_stream,
                'logEvents': [log_event]
            }
            
            if self.sequence_token:
                kwargs['sequenceToken'] = self.sequence_token
            
            response = self.client.put_log_events(**kwargs)
            self.sequence_token = response.get('nextSequenceToken')
            
        except Exception as e:
            print(f"Error sending log to CloudWatch: {e}")


def setup_logging():
    
    
    logger = logging.getLogger('monitoring-demo')
    logger.setLevel(logging.DEBUG)
    
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(logging.INFO)
    console_formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    console_handler.setFormatter(console_formatter)
    logger.addHandler(console_handler)
    
    if cloudwatch_logs:
        cloudwatch_handler = CloudWatchHandler(
            LOG_GROUP_NAME, 
            LOG_STREAM_NAME, 
            cloudwatch_logs
        )
        cloudwatch_handler.setLevel(logging.DEBUG)
        cloudwatch_formatter = logging.Formatter(
            '%(asctime)s %(name)s %(levelname)s %(message)s'
        )
        cloudwatch_handler.setFormatter(cloudwatch_formatter)
        logger.addHandler(cloudwatch_handler)
    
    return logger


def process_request(request_id, logger):
    
    
    logger.info(f"Processing request {request_id}")
    
    outcome = random.choices(
        ['success', 'warning', 'error', 'critical'],
        weights=[70, 15, 10, 5]
    )[0]
    
    processing_time = random.uniform(0.1, 2.0)
    time.sleep(processing_time)
    
    if outcome == 'success':
        logger.info(f"Request {request_id} completed successfully in {processing_time:.2f}s")
    elif outcome == 'warning':
        logger.warning(f"Request {request_id} completed with warnings: High latency detected")
    elif outcome == 'error':
        logger.error(f"Request {request_id} failed: Database connection timeout")
    elif outcome == 'critical':
        logger.critical(f"Request {request_id} failed: SECURITY: Unauthorized access attempt detected")
    
    return outcome


def publish_metrics(logger):
    
    if not cloudwatch_logs:
        return
    
    try:
        cloudwatch = boto3.client('cloudwatch', region_name=AWS_REGION)
        
        cloudwatch.put_metric_data(
            Namespace='DevSecOps/Demo',
            MetricData=[
                {
                    'MetricName': 'RequestProcessed',
                    'Value': 1.0,
                    'Unit': 'Count',
                    'Timestamp': datetime.utcnow()
                }
            ]
        )
        logger.debug("Metrics published to CloudWatch")
    except Exception as e:
        logger.error(f"Failed to publish metrics: {e}")


def main():
    
    
    logger = setup_logging()
    logger.info("=" * 60)
    logger.info("Monitoring Demo Application Started")
    logger.info("=" * 60)
    logger.info(f"Log Group: {LOG_GROUP_NAME}")
    logger.info(f"Log Stream: {LOG_STREAM_NAME}")
    logger.info(f"AWS Region: {AWS_REGION}")
    
    if not cloudwatch_logs:
        logger.warning("CloudWatch integration is disabled - logs will only appear in console")
    
    try:
        request_count = 0
        
        max_requests = 20
        
        while request_count < max_requests:
            request_count += 1
            request_id = f"REQ-{datetime.now().strftime('%Y%m%d%H%M%S')}-{request_count:04d}"
            
            outcome = process_request(request_id, logger)
            
            if request_count % 5 == 0:
                publish_metrics(logger)
            
            time.sleep(random.uniform(1, 3))
        
        logger.info("=" * 60)
        logger.info(f"Application completed - Processed {request_count} requests")
        logger.info("=" * 60)
        
    except KeyboardInterrupt:
        logger.info("\nApplication interrupted by user")
    except Exception as e:
        logger.critical(f"Application crashed: {e}", exc_info=True)
        sys.exit(1)


if __name__ == "__main__":
    main()
