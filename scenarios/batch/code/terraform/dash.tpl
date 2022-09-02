{
    "lenses": {
      "0": {
        "order": 0,
        "parts": {
          "0": {
            "position": {
              "x": 0,
              "y": 0,
              "colSpan": 6,
              "rowSpan": 4
            },
            "metadata": {
              "inputs": [],
              "type": "Extension/HubsExtension/PartType/MarkdownPart",
              "settings": {
                "content": {
                  "settings": {
                    "content": "\n<img src=\"https://github.com/mkiernan/azfinsim/raw/master/img/azfinsim.png\">\n\nFor more information, please see the <a href=\"https://github.com/mkiernan/azfinsim\">azfinsim github</a>\nFor more information on __Azure Batch__ please see: https://azure.microsoft.com/en-us/services/batch/. \n",
                    "title": "azfinsim",
                    "subtitle": "Azure Batch Risk Simulation",
                    "markdownSource": 1
                  }
                }
              }
            }
          },
          "1": {
            "position": {
              "x": 6,
              "y": 0,
              "colSpan": 6,
              "rowSpan": 4
            },
            "metadata": {
              "inputs": [
                {
                  "name": "sharedTimeRange",
                  "isOptional": true
                },
                {
                  "name": "options",
                  "value": {
                    "chart": {
                      "metrics": [
                        {
                          "resourceMetadata": {
                            "id": "${provider_path}/Microsoft.Cache/Redis/${cache_name}"
                          },
                          "name": "cacheWrite",
                          "aggregationType": 4,
                          "namespace": "microsoft.cache/redis",
                          "metricVisualization": {
                            "displayName": "Cache Write"
                          }
                        },
                        {
                          "resourceMetadata": {
                            "id": "${provider_path}/Microsoft.Cache/Redis/${cache_name}"
                          },
                          "name": "cacheWrite",
                          "aggregationType": 3,
                          "namespace": "microsoft.cache/redis",
                          "metricVisualization": {
                            "displayName": "Cache Write"
                          }
                        }
                      ],
                      "title": "Avg Cache Write and Max Cache Write for ${cache_name}",
                      "titleKind": 1,
                      "visualization": {
                        "chartType": 2,
                        "legendVisualization": {
                          "isVisible": true,
                          "position": 2,
                          "hideSubtitle": false
                        },
                        "axisVisualization": {
                          "x": {
                            "isVisible": true,
                            "axisType": 2
                          },
                          "y": {
                            "isVisible": true,
                            "axisType": 1
                          }
                        }
                      },
                      "timespan": {
                        "relative": {
                          "duration": 86400000
                        },
                        "showUTCTime": false,
                        "grain": 1
                      }
                    }
                  },
                  "isOptional": true
                }
              ],
              "type": "Extension/HubsExtension/PartType/MonitorChartPart",
              "settings": {
                "content": {
                  "options": {
                    "chart": {
                      "metrics": [
                        {
                          "resourceMetadata": {
                            "id": "${provider_path}/Microsoft.Cache/Redis/${cache_name}"
                          },
                          "name": "cacheWrite",
                          "aggregationType": 4,
                          "namespace": "microsoft.cache/redis",
                          "metricVisualization": {
                            "displayName": "Cache Write"
                          }
                        },
                        {
                          "resourceMetadata": {
                            "id": "${provider_path}/Microsoft.Cache/Redis/${cache_name}"
                          },
                          "name": "cacheWrite",
                          "aggregationType": 3,
                          "namespace": "microsoft.cache/redis",
                          "metricVisualization": {
                            "displayName": "Cache Write"
                          }
                        }
                      ],
                      "title": "Avg Cache Write and Max Cache Write for ${cache_name}",
                      "titleKind": 1,
                      "visualization": {
                        "chartType": 2,
                        "legendVisualization": {
                          "isVisible": true,
                          "position": 2,
                          "hideSubtitle": false
                        },
                        "axisVisualization": {
                          "x": {
                            "isVisible": true,
                            "axisType": 2
                          },
                          "y": {
                            "isVisible": true,
                            "axisType": 1
                          }
                        },
                        "disablePinning": true
                      }
                    }
                  }
                }
              },
              "filters": {
                "MsPortalFx_TimeRange": {
                  "model": {
                    "format": "local",
                    "granularity": "auto",
                    "relative": "1440m"
                  }
                }
              }
            }
          },
          "2": {
            "position": {
              "x": 0,
              "y": 4,
              "colSpan": 6,
              "rowSpan": 4
            },
            "metadata": {
              "inputs": [
                {
                  "name": "sharedTimeRange",
                  "isOptional": true
                },
                {
                  "name": "options",
                  "value": {
                    "chart": {
                      "metrics": [
                        {
                          "resourceMetadata": {
                            "id": "${provider_path}/Microsoft.Cache/Redis/${cache_name}"
                          },
                          "name": "connectedclients",
                          "aggregationType": 3,
                          "namespace": "microsoft.cache/redis",
                          "metricVisualization": {
                            "displayName": "Connected Clients"
                          }
                        },
                        {
                          "resourceMetadata": {
                            "id": "${provider_path}/Microsoft.Cache/Redis/${cache_name}"
                          },
                          "name": "allconnectedclients",
                          "aggregationType": 3,
                          "namespace": "microsoft.cache/redis",
                          "metricVisualization": {
                            "displayName": "Connected Clients (Instance Based)"
                          }
                        },
                        {
                          "resourceMetadata": {
                            "id": "${provider_path}/Microsoft.Cache/Redis/${cache_name}"
                          },
                          "name": "connectedclients0",
                          "aggregationType": 3,
                          "namespace": "microsoft.cache/redis",
                          "metricVisualization": {
                            "displayName": "Connected Clients (Shard 0)"
                          }
                        }
                      ],
                      "title": "Max Connected Clients, Max Connected Clients (Instance Based), and Max Connected Clients (Shard 0) for ${cache_name}",
                      "titleKind": 1,
                      "visualization": {
                        "chartType": 2,
                        "legendVisualization": {
                          "isVisible": true,
                          "position": 2,
                          "hideSubtitle": false
                        },
                        "axisVisualization": {
                          "x": {
                            "isVisible": true,
                            "axisType": 2
                          },
                          "y": {
                            "isVisible": true,
                            "axisType": 1
                          }
                        }
                      },
                      "timespan": {
                        "relative": {
                          "duration": 86400000
                        },
                        "showUTCTime": false,
                        "grain": 1
                      }
                    }
                  },
                  "isOptional": true
                }
              ],
              "type": "Extension/HubsExtension/PartType/MonitorChartPart",
              "settings": {
                "content": {
                  "options": {
                    "chart": {
                      "metrics": [
                        {
                          "resourceMetadata": {
                            "id": "${provider_path}/Microsoft.Cache/Redis/${cache_name}"
                          },
                          "name": "connectedclients",
                          "aggregationType": 3,
                          "namespace": "microsoft.cache/redis",
                          "metricVisualization": {
                            "displayName": "Connected Clients"
                          }
                        },
                        {
                          "resourceMetadata": {
                            "id": "${provider_path}/Microsoft.Cache/Redis/${cache_name}"
                          },
                          "name": "allconnectedclients",
                          "aggregationType": 3,
                          "namespace": "microsoft.cache/redis",
                          "metricVisualization": {
                            "displayName": "Connected Clients (Instance Based)"
                          }
                        },
                        {
                          "resourceMetadata": {
                            "id": "${provider_path}/Microsoft.Cache/Redis/${cache_name}"
                          },
                          "name": "connectedclients0",
                          "aggregationType": 3,
                          "namespace": "microsoft.cache/redis",
                          "metricVisualization": {
                            "displayName": "Connected Clients (Shard 0)"
                          }
                        }
                      ],
                      "title": "Max Connected Clients, Max Connected Clients (Instance Based), and Max Connected Clients (Shard 0) for ${cache_name}",
                      "titleKind": 1,
                      "visualization": {
                        "chartType": 2,
                        "legendVisualization": {
                          "isVisible": true,
                          "position": 2,
                          "hideSubtitle": false
                        },
                        "axisVisualization": {
                          "x": {
                            "isVisible": true,
                            "axisType": 2
                          },
                          "y": {
                            "isVisible": true,
                            "axisType": 1
                          }
                        },
                        "disablePinning": true
                      }
                    }
                  }
                }
              },
              "filters": {
                "MsPortalFx_TimeRange": {
                  "model": {
                    "format": "local",
                    "granularity": "auto",
                    "relative": "1440m"
                  }
                }
              }
            }
          },
          "3": {
            "position": {
              "x": 6,
              "y": 4,
              "colSpan": 6,
              "rowSpan": 4
            },
            "metadata": {
              "inputs": [
                {
                  "name": "sharedTimeRange",
                  "isOptional": true
                },
                {
                  "name": "options",
                  "value": {
                    "chart": {
                      "metrics": [
                        {
                          "resourceMetadata": {
                            "id": "${provider_path}/Microsoft.Cache/Redis/${cache_name}"
                          },
                          "name": "getcommands",
                          "aggregationType": 1,
                          "namespace": "microsoft.cache/redis",
                          "metricVisualization": {
                            "displayName": "Gets"
                          }
                        },
                        {
                          "resourceMetadata": {
                            "id": "${provider_path}/Microsoft.Cache/Redis/${cache_name}"
                          },
                          "name": "setcommands",
                          "aggregationType": 1,
                          "namespace": "microsoft.cache/redis",
                          "metricVisualization": {
                            "displayName": "Sets"
                          }
                        },
                        {
                          "resourceMetadata": {
                            "id": "${provider_path}/Microsoft.Cache/Redis/${cache_name}"
                          },
                          "name": "totalcommandsprocessed",
                          "aggregationType": 1,
                          "namespace": "microsoft.cache/redis",
                          "metricVisualization": {
                            "displayName": "Total Operations"
                          }
                        }
                      ],
                      "title": "Sum Gets, Sum Sets, and Sum Total Operations for ${cache_name}",
                      "titleKind": 1,
                      "visualization": {
                        "chartType": 2,
                        "legendVisualization": {
                          "isVisible": true,
                          "position": 2,
                          "hideSubtitle": false
                        },
                        "axisVisualization": {
                          "x": {
                            "isVisible": true,
                            "axisType": 2
                          },
                          "y": {
                            "isVisible": true,
                            "axisType": 1
                          }
                        }
                      },
                      "timespan": {
                        "relative": {
                          "duration": 86400000
                        },
                        "showUTCTime": false,
                        "grain": 1
                      }
                    }
                  },
                  "isOptional": true
                }
              ],
              "type": "Extension/HubsExtension/PartType/MonitorChartPart",
              "settings": {
                "content": {
                  "options": {
                    "chart": {
                      "metrics": [
                        {
                          "resourceMetadata": {
                            "id": "${provider_path}/Microsoft.Cache/Redis/${cache_name}"
                          },
                          "name": "getcommands",
                          "aggregationType": 1,
                          "namespace": "microsoft.cache/redis",
                          "metricVisualization": {
                            "displayName": "Gets"
                          }
                        },
                        {
                          "resourceMetadata": {
                            "id": "${provider_path}/Microsoft.Cache/Redis/${cache_name}"
                          },
                          "name": "setcommands",
                          "aggregationType": 1,
                          "namespace": "microsoft.cache/redis",
                          "metricVisualization": {
                            "displayName": "Sets"
                          }
                        },
                        {
                          "resourceMetadata": {
                            "id": "${provider_path}/Microsoft.Cache/Redis/${cache_name}"
                          },
                          "name": "totalcommandsprocessed",
                          "aggregationType": 1,
                          "namespace": "microsoft.cache/redis",
                          "metricVisualization": {
                            "displayName": "Total Operations"
                          }
                        }
                      ],
                      "title": "Sum Gets, Sum Sets, and Sum Total Operations for ${cache_name}",
                      "titleKind": 1,
                      "visualization": {
                        "chartType": 2,
                        "legendVisualization": {
                          "isVisible": true,
                          "position": 2,
                          "hideSubtitle": false
                        },
                        "axisVisualization": {
                          "x": {
                            "isVisible": true,
                            "axisType": 2
                          },
                          "y": {
                            "isVisible": true,
                            "axisType": 1
                          }
                        },
                        "disablePinning": true
                      }
                    }
                  }
                }
              },
              "filters": {
                "MsPortalFx_TimeRange": {
                  "model": {
                    "format": "local",
                    "granularity": "auto",
                    "relative": "1440m"
                  }
                }
              }
            }
          },
          "4": {
            "position": {
              "x": 0,
              "y": 8,
              "colSpan": 6,
              "rowSpan": 4
            },
            "metadata": {
              "inputs": [
                {
                  "name": "sharedTimeRange",
                  "isOptional": true
                },
                {
                  "name": "options",
                  "value": {
                    "chart": {
                      "metrics": [
                        {
                          "resourceMetadata": {
                            "id": "${provider_path}/Microsoft.Cache/Redis/${cache_name}"
                          },
                          "name": "percentProcessorTime",
                          "aggregationType": 3,
                          "namespace": "microsoft.cache/redis",
                          "metricVisualization": {
                            "displayName": "CPU"
                          }
                        }
                      ],
                      "title": "Max CPU for ${cache_name}",
                      "titleKind": 1,
                      "visualization": {
                        "chartType": 2,
                        "legendVisualization": {
                          "isVisible": true,
                          "position": 2,
                          "hideSubtitle": false
                        },
                        "axisVisualization": {
                          "x": {
                            "isVisible": true,
                            "axisType": 2
                          },
                          "y": {
                            "isVisible": true,
                            "axisType": 1
                          }
                        }
                      },
                      "timespan": {
                        "relative": {
                          "duration": 86400000
                        },
                        "showUTCTime": false,
                        "grain": 1
                      }
                    }
                  },
                  "isOptional": true
                }
              ],
              "type": "Extension/HubsExtension/PartType/MonitorChartPart",
              "settings": {
                "content": {
                  "options": {
                    "chart": {
                      "metrics": [
                        {
                          "resourceMetadata": {
                            "id": "${provider_path}/Microsoft.Cache/Redis/${cache_name}"
                          },
                          "name": "percentProcessorTime",
                          "aggregationType": 3,
                          "namespace": "microsoft.cache/redis",
                          "metricVisualization": {
                            "displayName": "CPU"
                          }
                        }
                      ],
                      "title": "Max CPU for ${cache_name}",
                      "titleKind": 1,
                      "visualization": {
                        "chartType": 2,
                        "legendVisualization": {
                          "isVisible": true,
                          "position": 2,
                          "hideSubtitle": false
                        },
                        "axisVisualization": {
                          "x": {
                            "isVisible": true,
                            "axisType": 2
                          },
                          "y": {
                            "isVisible": true,
                            "axisType": 1
                          }
                        },
                        "disablePinning": true
                      }
                    }
                  }
                }
              },
              "filters": {
                "MsPortalFx_TimeRange": {
                  "model": {
                    "format": "local",
                    "granularity": "auto",
                    "relative": "1440m"
                  }
                }
              }
            }
          },
          "5": {
            "position": {
              "x": 6,
              "y": 8,
              "colSpan": 6,
              "rowSpan": 4
            },
            "metadata": {
              "inputs": [
                {
                  "name": "sharedTimeRange",
                  "isOptional": true
                },
                {
                  "name": "options",
                  "value": {
                    "chart": {
                      "metrics": [
                        {
                          "resourceMetadata": {
                            "id": "${provider_path}/Microsoft.Cache/Redis/${cache_name}"
                          },
                          "name": "totalkeys",
                          "aggregationType": 3,
                          "namespace": "microsoft.cache/redis",
                          "metricVisualization": {
                            "displayName": "Total Keys"
                          }
                        },
                        {
                          "resourceMetadata": {
                            "id": "${provider_path}/Microsoft.Cache/Redis/${cache_name}"
                          },
                          "name": "evictedkeys",
                          "aggregationType": 1,
                          "namespace": "microsoft.cache/redis",
                          "metricVisualization": {
                            "displayName": "Evicted Keys"
                          }
                        },
                        {
                          "resourceMetadata": {
                            "id": "${provider_path}/Microsoft.Cache/Redis/${cache_name}"
                          },
                          "name": "expiredkeys",
                          "aggregationType": 1,
                          "namespace": "microsoft.cache/redis",
                          "metricVisualization": {
                            "displayName": "Expired Keys"
                          }
                        }
                      ],
                      "title": "Max Total Keys, Sum Evicted Keys, and Sum Expired Keys for ${cache_name}",
                      "titleKind": 1,
                      "visualization": {
                        "chartType": 2,
                        "legendVisualization": {
                          "isVisible": true,
                          "position": 2,
                          "hideSubtitle": false
                        },
                        "axisVisualization": {
                          "x": {
                            "isVisible": true,
                            "axisType": 2
                          },
                          "y": {
                            "isVisible": true,
                            "axisType": 1
                          }
                        }
                      },
                      "timespan": {
                        "relative": {
                          "duration": 86400000
                        },
                        "showUTCTime": false,
                        "grain": 1
                      }
                    }
                  },
                  "isOptional": true
                }
              ],
              "type": "Extension/HubsExtension/PartType/MonitorChartPart",
              "settings": {
                "content": {
                  "options": {
                    "chart": {
                      "metrics": [
                        {
                          "resourceMetadata": {
                            "id": "${provider_path}/Microsoft.Cache/Redis/${cache_name}"
                          },
                          "name": "totalkeys",
                          "aggregationType": 3,
                          "namespace": "microsoft.cache/redis",
                          "metricVisualization": {
                            "displayName": "Total Keys"
                          }
                        },
                        {
                          "resourceMetadata": {
                            "id": "${provider_path}/Microsoft.Cache/Redis/${cache_name}"
                          },
                          "name": "evictedkeys",
                          "aggregationType": 1,
                          "namespace": "microsoft.cache/redis",
                          "metricVisualization": {
                            "displayName": "Evicted Keys"
                          }
                        },
                        {
                          "resourceMetadata": {
                            "id": "${provider_path}/Microsoft.Cache/Redis/${cache_name}"
                          },
                          "name": "expiredkeys",
                          "aggregationType": 1,
                          "namespace": "microsoft.cache/redis",
                          "metricVisualization": {
                            "displayName": "Expired Keys"
                          }
                        }
                      ],
                      "title": "Max Total Keys, Sum Evicted Keys, and Sum Expired Keys for ${cache_name}",
                      "titleKind": 1,
                      "visualization": {
                        "chartType": 2,
                        "legendVisualization": {
                          "isVisible": true,
                          "position": 2,
                          "hideSubtitle": false
                        },
                        "axisVisualization": {
                          "x": {
                            "isVisible": true,
                            "axisType": 2
                          },
                          "y": {
                            "isVisible": true,
                            "axisType": 1
                          }
                        },
                        "disablePinning": true
                      }
                    }
                  }
                }
              },
              "filters": {
                "MsPortalFx_TimeRange": {
                  "model": {
                    "format": "local",
                    "granularity": "auto",
                    "relative": "1440m"
                  }
                }
              }
            }
          }
        }
      }
    },
    "metadata": {
      "model": {
        "timeRange": {
          "value": {
            "relative": {
              "duration": 24,
              "timeUnit": 1
            }
          },
          "type": "MsPortalFx.Composition.Configuration.ValueTypes.TimeRange"
        },
        "filterLocale": {
          "value": "en-us"
        },
        "filters": {
          "value": {
            "MsPortalFx_TimeRange": {
              "model": {
                "format": "utc",
                "granularity": "1 minute",
                "relative": "1h"
              },
              "displayCache": {
                "name": "UTC Time",
                "value": "Past hour"
              },
              "filteredPartIds": [
                "StartboardPart-MonitorChartPart-f36bb59b-6dab-4a31-9eeb-cb46a6a91aba",
                "StartboardPart-MonitorChartPart-f36bb59b-6dab-4a31-9eeb-cb46a6a91ad6",
                "StartboardPart-MonitorChartPart-f36bb59b-6dab-4a31-9eeb-cb46a6a91aea",
                "StartboardPart-MonitorChartPart-f36bb59b-6dab-4a31-9eeb-cb46a6a91afe",
                "StartboardPart-MonitorChartPart-f36bb59b-6dab-4a31-9eeb-cb46a6a91b12"
              ]
            }
          }
        }
      }
    }
}