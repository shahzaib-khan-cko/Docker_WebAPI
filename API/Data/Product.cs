using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Amazon.DynamoDBv2.DataModel;

namespace API.Data
{
    [DynamoDBTable("products")]
    public class Product
    {
        [DynamoDBHashKey("category")]
        public string? Category { get; set; }

        [DynamoDBRangeKey("name")]
        public string? Name { get; set; }

        [DynamoDBProperty("description")]
        public string? Description { get; set; }

        [DynamoDBProperty("price")]
        public decimal Price { get; set; }
    }
}