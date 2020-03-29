using System;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using System.Net.Http;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;

namespace ZipImagesFunction
{
    public static class ProcessZipBlob
    {
        [FunctionName("ProcessZipBlob")]
        public static async Task Run([BlobTrigger("zipimageblob/{name}")]
                                      CloudBlockBlob cloudBlockBlob,
                                      [Blob("zipimageblob/{name}", FileAccess.ReadWrite)]
                                      byte[] blobContents, ILogger log)            
        {
            log.LogInformation($"{cloudBlockBlob.Name}");

            var cl = new HttpClient();
            var zm = new ZipModel()
            {

                Zip = cloudBlockBlob.Name

            };

            var zipWorkflowURL = Environment.GetEnvironmentVariable("ZIP_WORKFLOW_URL");
            var zms = JsonConvert.SerializeObject(zm);
            var contnet = new StringContent(zms, Encoding.UTF8, "application/json");
            var response = await cl.PostAsync(zipWorkflowURL, contnet);
            log.LogDebug(response.Content.ToString());

        }
    }

    public class ZipModel
    {

        [JsonProperty("zip")]
        public string Zip { get; set; }

    }
}
