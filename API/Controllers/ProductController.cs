using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using Amazon.DynamoDBv2.DataModel;
using API.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ProductController : ControllerBase
    {
        private readonly IDynamoDBContext _dynamoDBContext;

        public ProductController(IDynamoDBContext dynamoDBContext)
        {
            _dynamoDBContext = dynamoDBContext;
        }

        [Route("get/{category}/{productName}")]
        [HttpGet]
        public async Task<IActionResult> Get(string category, string productName)
        {
            // LoadAsync is used to load single item
            var product = await _dynamoDBContext.LoadAsync<Product>(category, productName);
            return Ok(product);
        }

        [Route("save")]
        [HttpPost]
        public async Task<IActionResult> Save(Product product)
        {
            // SaveAsync is used to put an item in DynamoDB, it will overwite if an item with the same primary key already exists
            await _dynamoDBContext.SaveAsync(product);
            return Ok();
        }

        [Route("delete/{category}/{productName}")]
        [HttpDelete]
        public async Task<IActionResult> Delete(string category, string productName)
        {
            // DeleteAsync is used to delete an item from DynamoDB
            await _dynamoDBContext.DeleteAsync<Product>(category, productName);
            return Ok();
        }
    }
}