using System;
using System.Net.Http;
using System.IO;
using System.IO.Compression;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;
using Newtonsoft.Json;


namespace ZipImagesFunction
{
    public static class ZipImagesFunction
    {

        private static CloudBlockBlob GetBlobReference(string containerNameString,
                                                        string imageNameString)
        {
        
            CloudBlobClient cloudBlobClient = null;
            CloudStorageAccount cloudStorageAccount = null;

            var connectionString = Environment.GetEnvironmentVariable("AzureWebJobsStorage");
            var couldParse = CloudStorageAccount.TryParse(connectionString, out cloudStorageAccount);
            if (couldParse == false)
                return null;

            cloudBlobClient = cloudStorageAccount.CreateCloudBlobClient();
            var blobContainerReference = cloudBlobClient.GetContainerReference(containerNameString);
            var blobReference = blobContainerReference.GetBlockBlobReference(imageNameString);
            return blobReference;

        }
        
        private static async Task<byte[]> DownloadImageFromBlobAsync(string imageNameString)
        {
        
            var containerNameString = Environment.GetEnvironmentVariable("BIG_IMAGE_BLOB_NAME");
            var blobReference = GetBlobReference(containerNameString, imageNameString);

            var ms = new MemoryStream();
            await blobReference.DownloadToStreamAsync(ms);
            return ms.ToArray();

        }

        private static async Task UploadImageToBlobAsync(byte[] uploadBytesArray)
        {

            var containerNameString = Environment.GetEnvironmentVariable("ZIP_IMAGE_BLOB_NAME");
            var timeString = DateTime.Now.Ticks.ToString();            
            var zipImagePrefix = Environment.GetEnvironmentVariable("ZIP_IMAGE_PREFIX");
            var uploadFileNameString = $"{zipImagePrefix}{timeString}.zip";

            var blobReference = GetBlobReference(containerNameString, uploadFileNameString);

            await blobReference.UploadFromByteArrayAsync(uploadBytesArray, 0,
                                                            uploadBytesArray.Length);

        }

        [FunctionName("ZipImagesFunction")]
        public static async Task Run([HttpTrigger(AuthorizationLevel.Anonymous, "post",
                                    Route = "zip")]HttpRequestMessage request, ILogger log)
        {

            var contentString = await request.Content.ReadAsStringAsync();
            var imageNamesList = JsonConvert.DeserializeObject<List<string>>(contentString);

            using (var ms = new MemoryStream())
            {

                using (var zp = new ZipArchive(ms, ZipArchiveMode.Create, true))
                {

                    foreach (var imageNameString in imageNamesList)
                    {

                        var bts = await DownloadImageFromBlobAsync(imageNameString);
                        var ze = zp.CreateEntry(imageNameString);
                        using (var es = ze.Open())
                        {

                            using (var bw = new BinaryWriter(es))
                            {

                                bw.Write(bts);


                            }

                        }

                    }

                }

                await UploadImageToBlobAsync(ms.ToArray());

            }

        }
    }
}
