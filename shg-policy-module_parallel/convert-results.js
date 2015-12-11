#!/usr/bin/env node

(function() {
  var _ = require('underscore');
  var fs = require('fs');
  var d3 = require('d3');
  var path = require('path');

  function catValues(row) {
    var key, value;
    return [
      (function() {
        var _results;
        _results = [];
        for (key in row) {
          value = row[key];
          _results.push(value);
        }
        return _results;
      })()
    ].join(',');
  }

  function catKeys(row) {
    var key, value;
    return [
      (function() {
        var _results;
        _results = [];
        for (key in row) {
          value = row[key];
          _results.push(key);
        }
        return _results;
      })()
    ].join(',');
  }

  function collectPoliciesOnSameRow() {
    return fs.readFile(path.resolve(__dirname, 'prevalences.csv'), 'utf8', function(err, data) {
      var csv_rows, groups, rows;
      if (err) throw err;
      rows = d3.csv.parse(data);
      rows = _.map(rows, function(row) {
        var keys_to_mod;
        keys_to_mod = ['initiation_rate', 'cessation_rate', 'survivors', 'alive_smokers', 'smoking_prevalence', 'former_smokers', 'former_prevalence'];
        keys_to_mod.forEach(function(key) {
          row[key + '_' + row.policy_number] = row[key];
          return delete row[key];
        });
        return row;
      });
      rows = _.map(rows, function(row) {
        delete row['policy_number'];
        return row;
      });
      groups = d3.nest().key(function(d) {
        return "" + d.gender + "," + d.cohort + "," + d.year;
      }).entries(rows);
      groups.forEach(function(group, i) {
        var union;
        union = {};
        group.values.forEach(function(value) {
          return _(union).extend(value);
        });
        return group.values = union;
      });
      csv_rows = [];
      groups.forEach(function(group, index) {
        if (index === 0) csv_rows.push(catKeys(group.values));
        return csv_rows.push(catValues(group.values));
      });
      return fs.writeFile(path.resolve(__dirname, 'results.csv'), csv_rows.join('\n'), function(err) {
        if (err) throw err;
      });
    });
  }

  if (require.main === module) 
    collectPoliciesOnSameRow();

}).call(this);
