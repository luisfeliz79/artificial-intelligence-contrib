 // Process Swagger Content
 function processSwaggerContent(j,swaggerUrl) {



    // Check if Swagger 2.0
    if (j.swagger=="2.0") {
      console.log("Found Swagger 2.0");
      // Handle servers and basePath
      if (j.host)     { sample_host = j.host;        }
      if (j.basePath) { sample_basepath = j.basePath;}

      let host_endpoint = prompt("Please enter the Host:", sample_host);
      let base_path = prompt("Please enter the Base Url:", sample_basepath);

      j.host=host_endpoint;
      j.basePath = base_path;


    }

    // Check if OpenAPI 3.x
    if (j.openapi && j.openapi.startsWith("3.")) {
      console.log("Found OpenAPI 3.x");
      // Handle servers
      if (j.servers && j.servers.length>0 && j.servers[0].url) {
        sample_server = j.servers[0].url;
      }

      let server_endpoint = prompt("Please enter the Server URL:", sample_server);
      if (!j.servers) { j.servers = [ { url: server_endpoint } ]; }
      else           { j.servers[0].url = server_endpoint; }

      // Handle bearerAuth
        if (j.components && j.components.securitySchemes && j.components.securitySchemes) {
          console.log("Found securitySchemes");


          j.components.securitySchemes["bearerAuth"] = {};
          j.components.securitySchemes["bearerAuth"].type = "http";
          j.components.securitySchemes["bearerAuth"].scheme = "bearer";
          j.components.securitySchemes["bearerAuth"].bearerFormat = "JWT";
          j.components.securitySchemes["bearerAuth"].description = "Bearer token, to get a token use: az account get-access-token --resource \"resource\" --query \"accessToken\" --output tsv";
          j.security.push({ "bearerAuth": [] });

        }


      }



    let file_version = j.swagger ? j.swagger : j.openapi;

    j.info.description=j.info.description + "\n\n---\nUrl: [Swagger URL](" + swaggerUrl + ")  | OpenAPI version: " + file_version +" | [Load new file](index.html)";


    // the following lines will be replaced by docker/configurator, when it runs in a docker-container
    window.ui = SwaggerUIBundle({
      //url: "https://petstore.swagger.io/v2/swagger.json",
      spec: j,
      dom_id: '#swagger-ui',
      deepLinking: true,
      presets: [
        SwaggerUIBundle.presets.apis,
        SwaggerUIStandalonePreset
        ],
      plugins: [
        SwaggerUIBundle.plugins.DownloadUrl
      ]//,
      //layout: "StandaloneLayout"
    });


 }


// https://stackoverflow.com/questions/71206117/swaggeruibundle-specify-base-url

const sample_swaggerUrl = "https://petstore.swagger.io/v2/swagger.json";
let sample_host = "petstore.swagger.io";
let sample_basepath = "/v2";
let sample_server = "https://" + sample_host + sample_basepath;

window.onload = function() {
  //<editor-fold desc="Changeable Configuration Block">


  let swaggerUrl = prompt("Enter the Swagger URL:", sample_swaggerUrl);

  if (swaggerUrl=="") {swaggerUrl = sample_swaggerUrl;}

  // Different steps depending on json file or yaml file
  let isYaml = swaggerUrl.endsWith(".yaml") || swaggerUrl.endsWith(".yml");
  let isJson = swaggerUrl.endsWith(".json");

   if (isYaml) {
    swaggerJson = fetch(swaggerUrl).then(r => r.text().then(loaded => {

      console.log("Processing YAML");
      processSwaggerContent(jsyaml.load(loaded), swaggerUrl);

    }));
  }

  if (isJson)  {
    swaggerJson = fetch(swaggerUrl).then(r => r.json().then(loaded => {

      console.log("Processing JSON");
      processSwaggerContent(loaded, swaggerUrl);

    }));
  }

  //</editor-fold>
};


