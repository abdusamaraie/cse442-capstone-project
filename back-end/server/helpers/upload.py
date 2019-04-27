from constants.constants import GCS_BUCKET_NAME
from google.cloud import storage

'''
def upload_blob(bucket_name, source_file_name, destination_blob_name):
    """Uploads a file to the bucket."""
    storage_client = storage.Client()
    bucket = storage_client.get_bucket(bucket_name)
    blob = bucket.blob(destination_blob_name)

    blob.upload_from_filename(source_file_name)

    print('File {} uploaded to {}.'.format(
        source_file_name,
        destination_blob_name))
'''


def upload_profile_image(image, username):
    extension = image.filename.rsplit('.', 1)[1].lower()

    # Create a Cloud Storage client.
    gcs = storage.Client()

    # Get the bucket that the file will be uploaded to.
    bucket = gcs.get_bucket(GCS_BUCKET_NAME)

    # Create a new blob and upload the file's content.
    blob = bucket.blob(username + "_profile." + extension)

    blob.upload_from_string(image.read(), content_type=image.content_type)

    # The public URL can be used to directly access the uploaded file via HTTP.
    return blob.public_url


def upload_post_image():
    return None
