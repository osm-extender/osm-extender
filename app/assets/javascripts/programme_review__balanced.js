$(function() {
    $("#tabs").tabs();
});

google.load("visualization", "1", {packages:["corechart"]});

google.setOnLoadCallback(function () {
  updateStatus('Retreiving data.');
  setTimeout(drawCharts, 500);
});

function drawCharts() {
  updateStatus('Retreiving data.');

  $.ajax({
    url: "/programme_review/balanced_data",
    dataType:"json",
    async: false,
    success: function(data, status, jqXHR) {
      updateStatus('Processing data.');
      var number_zones_chart = new google.visualization.LineChart(document.getElementById('number_zones_chart'));
      var number_methods_chart = new google.visualization.LineChart(document.getElementById('number_methods_chart'));

      var number_zones_options = {
        focusTarget: 'category',
        hAxis: {
          format: 'MMM y',
        },
        vAxis: {
          maxValue: data['statistics']['zones']['max_value'],
          gridlines: {
            count: ((data['statistics']['zones']['max_value'] + 1) / 2) + 1,
          }
        },
        width: 750, height: 350
      };

      var number_methods_options = {
        focusTarget: 'category',
        hAxis: {
          format: 'MMM y',
        },
        vAxis: {
          maxValue: data['statistics']['methods']['max_value'],
          gridlines: {
            count: ((data['statistics']['methods']['max_value'] + 1) / 2) + 1,
          }
        },
        width: 750, height: 350
      };

      drawChart(data, number_zones_options, number_zones_chart, 'zone');
      drawChart(data, number_methods_options, number_methods_chart, 'method');

      writeScore(data, document.getElementById('number_zones_score'), 'zone');
      writeScore(data, document.getElementById('number_methods_score'), 'method');

      updateStatus('');
    }
  })
}


function drawChart(data, options, chart, type) {
  updateStatus('Processing chart data for' + type + 's.');

  type_key = type+'s';
  labels_key = type+'_labels';
  data_table = new google.visualization.DataTable();

  data_table.addColumn('date', 'Month');
  for(label in data[labels_key]) {
    data_table.addColumn('number', data[labels_key][label][0]);
  }

  for(date_key in data[type_key]) {
    row = new Array();
    date_key_split = date_key.split('_');
    row[0] = new Date(parseInt(date_key_split[0]), parseInt(date_key_split[1], 10)-1, 15);
    for(label in data[labels_key]) {
      label_key = data[labels_key][label][0];
      row.push(data[type_key][date_key][label_key]);
    }
    data_table.addRows([row]);
  }

  chart.draw(data_table, options);
}


function writeScore(data, div, type){
  updateStatus('Processing score data for ' + type + 's.');

  sd = data['statistics'][type+'s']['standard_deviation'];
  mv = data['statistics'][type+'s']['max_value'];
  score = Math.round(((mv - sd) / mv) * 100);
  score = 'Your score is ' + score + '%.';

  table =  "<table>";
  table +=   "<tr><th>" + capitaliseFirstLetter(type) + "</th><th>Total</th></tr>";
  for(label in data[type+'_labels']) {
    label_key = data[type+'_labels'][label][0];
    table += "<tr><td>" + label_key + "</td><td>" + data['statistics'][type+'s']['totals'][label_key] + "</td></tr>";
  }
  table += "</table>";

  div.innerHTML = score + '<br/>' + table;
}


function updateStatus(message) {
  $("#status_message").html(message);
}


function capitaliseFirstLetter(string) {
  return string[0].toUpperCase() + string.slice(1);
}