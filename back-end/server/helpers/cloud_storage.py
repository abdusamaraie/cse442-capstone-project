from constants.constants import GCS_BUCKET_NAME
from google.cloud import storage


def upload_profile_image(image, username):
    extension = image.filename.rsplit('.', 1)[1].lower()
    # Create a Cloud Storage client.
    gcs = storage.Client()

    # Get the bucket that the file will be uploaded to.
    bucket = gcs.get_bucket(GCS_BUCKET_NAME)

    # Create a new blob and upload the file's content.
    blob = bucket.blob("profile_images/{}_profile.{}".format(username, extension))

    blob.upload_from_string(image.read(), content_type=image.content_type)

    # The public URL can be used to directly access the uploaded file via HTTP.
    return blob.public_url


def delete_profile_image(image_url):
    """Deletes a blob from the bucket."""
    blob_name = image_url.replace("https://storage.googleapis.com/cachr-images/", '', 1)
    storage_client = storage.Client()
    bucket = storage_client.get_bucket(GCS_BUCKET_NAME)
    blob = bucket.blob(blob_name)

    blob.delete()


def upload_post_image():
    return None
