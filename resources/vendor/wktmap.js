var raster;
var source;
var vector;
var map;
var features = new ol.Collection();
var format = new ol.format.WKT();

var fill = new ol.style.Fill({
  color: 'rgba(210, 122, 167,0.2)'
});
var stroke = new ol.style.Stroke({
  color: '#B40404',
  width: 2
});

var styles = [
  new ol.style.Style({
    image: new ol.style.Circle({
      fill: fill,
      stroke: stroke,
      radius: 5
    }),
    fill: fill,
    stroke: stroke
  })
];


function createVector() {
  vector = new ol.layer.Vector({
    source: new ol.source.Vector({ features: features }),
    style: styles
  });
}

function init() {
  createVector();
  raster = new ol.layer.Tile({
    source: new ol.source.OSM()
  });
  map = new ol.Map({
    layers: [raster, vector],
    target: 'map',
    view: new ol.View({
      center: [-11000000, 4600000],
      zoom: 4
    })
  });
}

// Plot wkt string on map
function plotWKT(myData) {
  var new_feature;

  wkt_string = myData;
  try {
    new_feature = format.readFeature(wkt_string);
  } catch (err) {}


  map.removeLayer(vector);
  features.clear();
  new_feature.getGeometry().transform('EPSG:4326', 'EPSG:3857');
  features.push(new_feature);

  vector = new ol.layer.Vector({
    source: new ol.source.Vector({ features: features }),
    style: styles
  });

  map.addLayer(vector);
  derived_feature = features.getArray()[0];
  extent = derived_feature.getGeometry().getExtent();
  minx = derived_feature.getGeometry().getExtent()[0];
  miny = derived_feature.getGeometry().getExtent()[1];
  maxx = derived_feature.getGeometry().getExtent()[2];
  maxy = derived_feature.getGeometry().getExtent()[3];
  centerx = (minx + maxx) / 2;
  centery = (miny + maxy) / 2;
  map.setView(new ol.View({
    center: [centerx, centery],
    zoom: 8
  }));
  map.getView().fit(extent, map.getSize());
}
