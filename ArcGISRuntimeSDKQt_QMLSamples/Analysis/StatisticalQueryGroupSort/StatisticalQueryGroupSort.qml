// [WriteFile Name=StatisticalQueryGroupSort, Category=Analysis]
// [Legal]
// Copyright 2017 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// [Legal]

import QtQuick 2.6
import QtQuick.Controls 2.2
import Esri.ArcGISRuntime 100.12

Rectangle {
    id: rootRectangle
    clip: true
    width: 800
    height: 600

    

    ServiceFeatureTable {
        id: censusTable
        url: "https://services.arcgis.com/jIL9msH9OI208GCb/arcgis/rest/services/Counties_Obesity_Inactivity_Diabetes_2013/FeatureServer/0"

        Component.onCompleted: load();

        onLoadStatusChanged: {
            if (loadStatus !== Enums.LoadStatusLoaded)
                return;

            const fieldModel = [];
            for (let i = 0; i < fields.length; i++) {
                fieldModel.push(fields[i].name);
            }
            statisticOptionsPage.fields = fieldModel;
        }

        onQueryStatisticsStatusChanged: {
            if (queryStatisticsStatus === Enums.TaskStatusErrored) {
                resultsModel.clear();
                resultsModel.append({"section": "", "statistic": "Error. %1".arg(error.message)});
                return;
            }

            if (queryStatisticsStatus !== Enums.TaskStatusCompleted)
                return;

            // reset the model and check the results
            resultsModel.clear();
            if (!queryStatisticsResult) {
                resultsModel.append({"section": "", "statistic": "Error. %1".arg(error.message)});
                return;
            }

            // iterate the results and add to a model
            const iter = queryStatisticsResult.iterator;
            while (iter.hasNext) {
                const record = iter.next();
                const sectionString = JSON.stringify(record.group).replace("{","").replace("}","");

                for (let statKey in record.statistics) {
                    if (record.statistics.hasOwnProperty(statKey)) {
                        const result = {
                            "section" : sectionString,
                            "statistic" : statKey + ": " + record.statistics[statKey]
                        };
                        resultsModel.append(result)
                    }
                }
            }
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent

        // Initial page is the OptionsPage
        initialItem: OptionsPage {
            id: statisticOptionsPage
            width: parent.width
            height: parent.height
            onStatisticButtonClicked: {
                // create the parameter object
                const params = ArcGISRuntimeEnvironment.createObject("StatisticsQueryParameters");

                // add the statistic definition objects
                const statisticDefinitions = [];
                for (let i = 0; i < statisticsModel.count; i++) {
                    const statistic = statisticsModel.get(i);
                    const definition = ArcGISRuntimeEnvironment.createObject("StatisticDefinition", {
                                                                                 onFieldName: statistic.field,
                                                                                 statisticType: statisticStringToEnum(statistic.statistic)
                                                                             });
                    statisticDefinitions.push(definition);
                }
                params.statisticDefinitions = statisticDefinitions;

                // set the grouping fields
                params.groupByFieldNames = groupingFields;

                // add the order by objects
                const orderBys = [];
                for (let j = 0; j < orderByModel.count; j++) {
                    const group = orderByModel.get(j);
                    const orderBy = ArcGISRuntimeEnvironment.createObject("OrderBy", {
                                                                              fieldName: group.field,
                                                                              sortOrder: orderStringToEnum(group.order)
                                                                          });
                    orderBys.push(orderBy);
                }
                params.orderByFields = orderBys;

                // ignore counties with missing data
                params.whereClause = "\"State\" IS NOT NULL";

                // execute the query
                censusTable.queryStatistics(params);

                // show the results page
                stackView.push(resultsPage);
            }
        }

        // The ResultsPage is shown when a query is executed
        ResultsPage {
            id: resultsPage
            width: parent.width
            height: parent.height
            statisticResult: resultsModel
            onBackClicked: stackView.pop();
        }
    }

    // helper to convert from statistic type string to enum
    function statisticStringToEnum(statString) {
        switch(statString) {
        default:
        case "Average":
            return Enums.StatisticTypeAverage;
        case "Count":
            return Enums.StatisticTypeCount;
        case "Maximum":
            return Enums.StatisticTypeMaximum;
        case "Minimum":
            return Enums.StatisticTypeMinimum;
        case "Standard Deviation":
            return Enums.StatisticTypeStandardDeviation;
        case "Sum":
            return Enums.StatisticTypeSum;
        case "Variance":
            return Enums.StatisticTypeVariance;
        }
    }

    // helper to convert from sort order string to enum
    function orderStringToEnum(orderString) {
        switch(orderString) {
        default:
        case "Ascending":
            return Enums.SortOrderAscending;
        case "Descending":
            return Enums.SortOrderDescending;
        }
    }

    ListModel {
        id: resultsModel
    }
}
