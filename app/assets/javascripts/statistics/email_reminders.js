google.load("visualization", "1", {packages:["corechart"]});

google.setOnLoadCallback(function () {
  setTimeout(drawCharts, 500);
});

function drawCharts() {
  $.ajax({
    url: 'email_reminders.json',
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
        width: 1000, height: 350
      };
      number_options.vAxis.maxValue = graphStepSize(data['number']['max_value'], number_desired_steps) * (number_options.vAxis.gridlines.count - 1);

      var day_options = {
        focusTarget: 'category',
        isStacked: true,
        legend: {
          position: 'bottom'
        },
        colors: ['#3366cc', '#109618', '#dc3912', '#ff9900'],
        hAxis: {
          minValue: 0,
          gridlines: {
            count: graphGridLines(data['day']['max_value'], day_desired_steps)
          }
        },
        width: 1000, height: 350
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
        width: 1000, height: 350
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
    row = data[data_row];
    row[0] = new Date(row[0]);
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
  data_table.addColumn({
    type: 'number',
    label: 'Shares (Subscribed)'
  });
  data_table.addColumn({
    type: 'number',
    label: 'Shares (Unsubscribed)'
  });
  data_table.addColumn({
    type: 'number',
    label: 'Shares (Pending)'
  });

  data_table.addRow([ 'Mon', data[0][1], data[1][1]['subscribed'], data[1][1]['unsubscribed'], data[1][1]['pending'] ]);
  data_table.addRow([ 'Tue', data[0][2], data[1][2]['subscribed'], data[1][2]['unsubscribed'], data[1][2]['pending'] ]);
  data_table.addRow([ 'Wed', data[0][3], data[1][3]['subscribed'], data[1][3]['unsubscribed'], data[1][3]['pending'] ]);
  data_table.addRow([ 'Thu', data[0][4], data[1][4]['subscribed'], data[1][4]['unsubscribed'], data[1][4]['pending'] ]);
  data_table.addRow([ 'Fri', data[0][5], data[1][5]['subscribed'], data[1][5]['unsubscribed'], data[1][5]['pending'] ]);
  data_table.addRow([ 'Sat', data[0][6], data[1][6]['subscribed'], data[1][6]['unsubscribed'], data[1][6]['pending'] ]);
  data_table.addRow([ 'Sun', data[0][0], data[1][0]['subscribed'], data[1][0]['unsubscribed'], data[1][0]['pending'] ]);

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
