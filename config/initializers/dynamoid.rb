Dynamoid.configure do |config|
  config.adapter = 'aws_sdk' # This adapter establishes a connection to the DynamoDB servers using Amazon's own AWS gem.
  config.warn_on_scan = true
  case Rails.env 
    when 'production' then 
      config.namespace = "myairmyhealth-production" # To namespace tables created by Dynamoid from other tables you might have.
      config.warn_on_scan = false
    when 'development' then config.namespace = "myairmyhealth-development" # To namespace tables created by Dynamoid from other tables you might have.
    when 'test' then config.namespace = "myairmyhealth-test" # To namespace tables created by Dynamoid from other tables you might have.
    else config.namespace = "myairmyhealth-other"
  end
   # Output a warning to the logger when you perform a scan rather than a query on a table.
  config.partitioning = false # Spread writes randomly across the database. See "partitioning" below for more.
  config.partition_size = 200  # Determine the key space size that writes are randomly spread across.
  config.read_capacity = 50 # Read capacity for your tables
  config.write_capacity = 10 # Write capacity for your tables
end