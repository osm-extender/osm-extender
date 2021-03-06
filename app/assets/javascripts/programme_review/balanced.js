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
    url: 'balanced_data',
    dataType:"json",
    async: false,
    success: function(data, status, jqXHR) {
      updateStatus('Processing data.');

      var number_zones_steps = (data['statistics']['zones']['number']['max_value'] > 5) ?  graphGridLines(data['statistics']['zones']['number']['max_value'], 5) : data['statistics']['zones']['number']['max_value'];
      var number_methods_steps = (data['statistics']['methods']['number']['max_value'] > 5) ? graphGridLines(data['statistics']['methods']['number']['max_value'], 5) : data['statistics']['methods']['number']['max_value'];
      var time_zones_steps = Math.ceil(data['statistics']['zones']['time']['max_value'] / 60);
      var time_methods_steps = Math.ceil(data['statistics']['methods']['time']['max_value'] / 60);

      var number_zones_chart = new google.visualization.LineChart(document.getElementById('number_zones_chart'));
      var number_methods_chart = new google.visualization.LineChart(document.getElementById('number_methods_chart'));
      var time_zones_chart = new google.visualization.LineChart(document.getElementById('time_zones_chart'));
      var time_methods_chart = new google.visualization.LineChart(document.getElementById('time_methods_chart'));

      var number_zones_options = {
        focusTarget: 'category',
        vAxis: {
          gridlines: {
            count: number_zones_steps + 1
          }
        },
        width: 750, height: 350
      };
      number_zones_options.vAxis.maxValue = number_zones_steps * graphStepSize(data['statistics']['zones']['number']['max_value'], number_zones_steps);

      var number_methods_options = {
        focusTarget: 'category',
        vAxis: {
          gridlines: {
            count: number_methods_steps + 1
          }
        },
        width: 750, height: 350
      };
      number_methods_options.vAxis.maxValue = number_methods_steps * graphStepSize(data['statistics']['methods']['number']['max_value'], number_methods_steps);

      var time_zones_options = {
        focusTarget: 'category',
        vAxis: {
          title: 'Minutes',
          gridlines: {
            count: time_zones_steps + 1
          }
        },
        width: 750, height: 350
      };
      time_zones_options.vAxis.maxValue = time_zones_steps * 60;

      var time_methods_options = {
        focusTarget: 'category',
        vAxis: {
          title: 'Minutes',
          gridlines: {
            count: time_methods_steps + 1
          }
        },
        width: 750, height: 350
      };
      time_methods_options.vAxis.maxValue = time_methods_steps * 60;

      drawChart(data['zones']['number'], data['zone_labels'], number_zones_options, number_zones_chart, 'zone', 'number');
      drawChart(data['methods']['number'], data['method_labels'], number_methods_options, number_methods_chart, 'method', 'number');

      updateStatus('Processing score data for zones (by number).');
      writeScore(data['statistics']['zones']['number'], data['zone_labels'], 'Zone', document.getElementById('number_zones_score'));
      updateStatus('Processing score data for methods (by number).');
      writeScore(data['statistics']['methods']['number'], data['method_labels'], 'Method', document.getElementById('number_methods_score'));

      drawChart(data['zones']['time'], data['zone_labels'], time_zones_options, time_zones_chart, 'zone', 'time');
      drawChart(data['methods']['time'], data['method_labels'], time_methods_options, time_methods_chart, 'zone', 'time');

      updateStatus('Processing score data for zones (by time).');
      writeScore(data['statistics']['zones']['time'], data['zone_labels'], 'Zone', document.getElementById('time_zones_score'));
      updateStatus('Processing score data for methods (by time).');
      writeScore(data['statistics']['methods']['time'], data['method_labels'], 'Method', document.getElementById('time_methods_score'));

      updateStatus('');
    }
  })
}


function drawChart(data, labels, options, chart, z_or_m, n_or_t) {
  updateStatus('Processing chart data for ' + z_or_m + 's (by ' + n_or_t + ').');

  data_table = new google.visualization.DataTable();
  data_table.addColumn({
    type: 'date',
    label: 'Month',
    pattern: 'MMM yyyy'
  });
  for(label in labels) {
    data_table.addColumn({
      type: 'number',
      label: labels[label][0]
    });
  }

  for(date_key in data) {
    row = new Array();
    date_key_split = date_key.split('_');
    row[0] = new Date(parseInt(date_key_split[0]), parseInt(date_key_split[1], 10)-1, 15);
    for(label in labels) {
      row.push(data[date_key][labels[label][0]]);
    }
    index = data_table.addRow(row);
    if (index != null) {
      data_table.setFormattedValue(index, 0, $.datepicker.formatDate('MM yy', row[0]));
      if (n_or_t == 'time') {
        for (label in labels) {
          var column = parseInt(label) + 1;
          var minutes = data_table.getValue(index, column);
          var hours = Math.floor(minutes / 60);
          minutes = minutes % 60;
          var formatted = '';
          if (hours > 0) {
            formatted = hours + ' hours  ';
          }
          formatted = formatted + minutes + ' minutes';
          data_table.setFormattedValue(index, column, formatted);
        }
      }
    }
  }

  chart.draw(data_table, options);
}


function writeScore(data, labels, type_heading, div){
  sd = data['standard_deviation'];
  mv = data['max_value'];
  score = Math.round(((mv - sd) / mv) * 100);
  score = 'Your score is ' + score + '%.';

  table =  "<table>";
  table +=   "<tr><th>" + type_heading + "</th><th>Total</th></tr>";
  for(label in labels) {
    label_key = labels[label][0];
    table += "<tr><td>" + label_key + "</td><td>" + data['totals'][label_key] + "</td></tr>";
  }
  table += "</table>";

  div.innerHTML = score + '<br/>' + table;
}


function updateStatus(message) {
  $("#status_message").html(message);
}
