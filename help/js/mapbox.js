$( document ).ready(function() {
  var stationsURL = "http://api.citybik.es/v2/networks";
  // Skeleton GeoJSON format
  var networks = {
    "type": "FeatureCollection",
    "crs": {
      "type": "name",
      "properties": {
        "name": "urn:ogc:def:crs:OGC:1.3:CRS84"
      }
    },
    "features": new Array
  };

  // Create Mapbox map
  L.mapbox.accessToken = 'pk.eyJ1IjoiZ3N6YXRobWFyaSIsImEiOiI4YTUxYTE1NzUxMzJjY2NkMTQ3OWIzYjc5Yjc5ODYxNCJ9.ScogM8ryxXlVilaMRwWJYQ';
  var map = L.mapbox.map('map')
    .setView([30, 0], 2)
    .addLayer(L.mapbox.tileLayer('gszathmari.nc6mdh3k'));

  // Retrieve list of cities from Citybikes API
  $.get(stationsURL, function(data) {
      $.each(data.networks, function(index, network) {
        // Transform data to GeoJSON
        networks.features.push({
          "type": "Feature",
          "geometry": {
            "type": "Point",
            "coordinates": [
              network.location.longitude,
              network.location.latitude
            ]
          },
          "properties": {
            "title": network.location.city,
            "description": network.name,
            "marker-color": "#3f9ddd",
            "marker-size": "small",
            "marker-symbol": "bicycle"
          }
        });
      });
    }).done(function() {
      // Add markers to map
      var clusterGroup = new L.MarkerClusterGroup();
      var stationsLayer = L.mapbox.featureLayer(networks);
      map.addLayer(clusterGroup.addLayer(stationsLayer));
    });
});
