google.load("visualization", "1", {packages:["corechart"]});

google.setOnLoadCallback(function () {
  setTimeout(drawCharts, 500);
});

function drawCharts() {
  $.ajax({
    url: "/statistics/email_reminders.json",
    dataType:"json",
    async: false,
    success: function(data, status, jqXHR) {
      var number_desired_steps = 5;
      var day_desired_steps = 5;
      var item_desired_steps = 5;

      var number_chart = new google.visualization.LineChart(document.getElementById('number_chart'));
      var day_chart = new google.visualization.BarChart(document.getElementById('day_chart'));
      var item_chart = new google.visualization.BarChart(document.getElementById('item_chart'));

      var number_options = {
        focusTarget: 'category',
        vAxis: {
          minValue: 0,
          gridlines: {
            count: graphGridLines(data['number']['max_value'], number_desired_steps)
          }
        },
        legend: {position: 'none'},
        width: 750, height: 350
      };
      number_options.vAxis.maxValue = graphStepSize(data['number']['max_value'], number_desired_steps) * (number_options.vAxis.gridlines.count - 1);

      var day_options = {
        focusTarget: 'category',
        hAxis: {
          minValue: 0,
          gridlines: {
            count: graphGridLines(data['day']['max_value'], day_desired_steps)
          }
        },
        legend: {position: 'none'},
        width: 750, height: 350
      };
      day_options.hAxis.maxValue = graphStepSize(data['day']['max_value'], day_desired_steps) * (day_options.hAxis.gridlines.count - 1);

      var item_options = {
        focusTarget: 'category',
        hAxis: {
          minValue: 0,
          gridlines: {
            count: graphGridLines(data['item']['max_value'], item_desired_steps)
          }
        },
        legend: {position: 'none'},
        width: 750, height: 350
      };
      item_options.hAxis.maxValue = graphStepSize(data['item']['max_value'], item_desired_steps) * (item_options.hAxis.gridlines.count - 1);


      drawNumberChart(data['number']['data'], number_options, number_chart);
      drawDayChart(data['day']['data'], day_options, day_chart);
      drawItemChart(data['item']['data'], item_options, item_chart);
    }
  })
}

function drawNumberChart(data, options, chart) {
  data_table = new google.visualization.DataTable();
  data_table.addColumn({
    type: 'date',
    label: 'Date',
    pattern: 'DD MMM yyyy'
  });
  data_table.addColumn({
    type: 'number',
    label: 'Reminder Emails'
  });

  for(data_row in data) {
    row = new Array();
    row[0] = new Date(data[data_row]['date']);
    row[1] = data[data_row]['total'];
    data_table.addRow(row);
  }

  chart.draw(data_table, options);
}

function drawDayChart(data, options, chart) {
  data_table = new google.visualization.DataTable();
  data_table.addColumn({
    type: 'string',
    label: 'Day'
  });
  data_table.addColumn({
    type: 'number',
    label: 'Reminder Emails'
  });

  data_table.addRow(['Mon', data[1]]);
  data_table.addRow(['Tue', data[2]]);
  data_table.addRow(['Wed', data[3]]);
  data_table.addRow(['Thu', data[4]]);
  data_table.addRow(['Fri', data[5]]);
  data_table.addRow(['Sat', data[6]]);
  data_table.addRow(['Sun', data[0]]);

  chart.draw(data_table, options);
}

function drawItemChart(data, options, chart) {
  data_table = new google.visualization.DataTable();
  data_table.addColumn({
    type: 'string',
    label: 'Item'
  });
  data_table.addColumn({
    type: 'number',
    label: 'Used'
  });

  for(var key in data) {
    data_table.addRow([key, data[key]]);
  }

  chart.draw(data_table, options);
}