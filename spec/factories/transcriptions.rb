FactoryBot.define do
  factory :transcription do
    workflow
    group_id { "GROUP1A" }
    text { { "checkout_this": "metadata" } }
    status { 1 }
  end

  trait :full_json_blob do
    text { {
      "frame0": [{
        "user_ids": [11],
        "clusters_x": [1311.1291866028707, 666.5167464114833],
        "clusters_y": [788.11004784689, 781.8516746411483],
        "line_slope": 179.26252336428178,
        "slope_label": 1,
        "gutter_label": 0,
        "number_views": 1,
        "clusters_text": [
          ["[deletion][/deletion]"]
        ],
        "extract_index": [1],
        "gold_standard": [false],
        "low_consensus": true,
        "consensus_text": "[deletion][/deletion]",
        "consensus_score": 1.0
      }, {
        "user_ids": [1325796.0, 1325796.0, 1325796.0, 1325796.0, 1325796.0, 1325361.0, 1325361.0],
        "clusters_x": [913.9868111445219, 610.6879194904875],
        "clusters_y": [266.98410480295087, 271.5937382180552],
        "line_slope": 179.26252336428178,
        "slope_label": 1,
        "gutter_label": 0,
        "number_views": 7,
        "clusters_text": [
          ["Ms", "Ms", "", "", "", "Ms", ""],
          ["", "Z", "", "", "", "", ""],
          ["", "B", "", "", "", "", ""],
          ["", "Oak", "leland", "oakes", "oakes", "", "oakes"]
        ],
        "extract_index": [0, 0, 0, 0, 0, 0, 0],
        "gold_standard": [false, false, false, false, false, false, false],
        "low_consensus": true,
        "consensus_text": "Ms Z B oakes",
        "consensus_score": 2.0
      }, {
        "user_ids": [1325796.0, 22],
        "clusters_x": [1181.3243243243244, 860.2162162162163],
        "clusters_y": [222.93243243243245, 228.82432432432432],
        "line_slope": 179.26252336428178,
        "slope_label": 1,
        "gutter_label": 0,
        "number_views": 2,
        "clusters_text": [
          ["test", "test"]
        ],
        "extract_index": [0, 0],
        "gold_standard": [false, false],
        "low_consensus": true,
        "consensus_text": "test",
        "consensus_score": 2.0
      }, {
        "user_ids": [1325889.0, 1325803.0, 1325796.0, 1325796.0, 1325361.0, 1325361.0],
        "clusters_x": [778.8178944102211, 1384.2271593758257],
        "clusters_y": [138.78157983107482, 128.2726430438015],
        "line_slope": -0.221176437611867,
        "slope_label": 0,
        "gutter_label": 0,
        "number_views": 6,
        "clusters_text": [
          ["John's", "John's", "John", "John", "John", "John's"],
          ["Lelaud", "Lelaud", "leland", "leland", "leland", "Lelaud"],
          ["Sept", "Sept", "", "", "", "Sept"],
          ["18th", "18th", "", "", "", "18th"],
          ["1856", "1856", "", "", "", "1856"]
        ],
        "extract_index": [1, 0, 0, 1, 0, 1],
        "gold_standard": [false, false, false, false, false, false],
        "low_consensus": false,
        "consensus_text": "John's Lelaud Sept 18th 1856",
        "consensus_score": 3.0
      }, {
        "user_ids": [1325889.0, 1325796.0, 1325796.0, 1325796.0, 1325361.0, 1325361.0, 1325361.0, 33, 44, 1325361.0, 1325796.0, 1325361.0],
        "clusters_x": [608.7537704148516, 1000.84140625],
        "clusters_y": [260.2930537695804, 249.22500000000002],
        "line_slope": -0.221176437611867,
        "slope_label": 0,
        "gutter_label": 0,
        "number_views": 12,
        "clusters_text": [
          ["Mr", "Z", "", "", "Mr", "Me", "Mr", "", "", "Mr", "", "Mr"],
          ["Le.", "b", "b", "", "L", "L", "L", "", "", "LB", "", "L"],
          ["B", "", "", "", "B", "B", "B", "", "", "", "", "B"],
          ["Oakes", "oakes", "oakes", "oakes", "Oakes", "Oakes", "Oakes", "oakes", "oakes", "Oakes", "oakes", "oakes"]
        ],
        "extract_index": [0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0],
        "gold_standard": [false, false, false, false, false, false, false, false, false, false, false, false],
        "low_consensus": false,
        "consensus_text": "Mr L B oakes",
        "consensus_score": 5.25
      }, {
        "user_ids": [1325889.0, 1325796.0, 1325361.0, 1325361.0, 1325361.0, 1325841.0],
        "clusters_x": [667.4541769397135, 1390.6588578268288],
        "clusters_y": [305.36150800329324, 304.03032820448317],
        "line_slope": -0.221176437611867,
        "slope_label": 0,
        "gutter_label": 0,
        "number_views": 6,
        "clusters_text": [
          ["Dear", "Dear", "dear", "dear", "Dear", "Dear"],
          ["Sir", "sir", "sir", "sir", "Sir", "Sir."],
          ["I", "", "I", "I", "", "I"],
          ["have", "", "have", "have", "", "have"],
          ["just", "", "just", "just", "", "just"],
          ["recieved", "", "received", "received", "", "received"]
        ],
        "extract_index": [2, 2, 0, 0, 1, 0],
        "gold_standard": [false, false, false, false, false, false],
        "low_consensus": false,
        "consensus_text": "Dear sir I have just received",
        "consensus_score": 3.6666666666666665
      }, {
        "user_ids": [1325889.0, 1325361.0, 1325361.0],
        "clusters_x": [599.8771015810208, 1389.1773296798501],
        "clusters_y": [346.6687695098003, 349.7927641488854],
        "line_slope": -0.221176437611867,
        "slope_label": 0,
        "gutter_label": 0,
        "number_views": 3,
        "clusters_text": [
          ["information", "information", "information"],
          ["that", "that", "that"],
          ["a", "", "a"],
          ["fellow", "", "fellow"],
          ["of", "", "of"],
          ["mine", "", "mine"]
        ],
        "extract_index": [3, 1, 0],
        "gold_standard": [false, false, false],
        "low_consensus": true,
        "consensus_text": "information that a fellow of mine",
        "consensus_score": 2.3333333333333335
      }, {
        "user_ids": [1325889.0, 1325800.0, 1325361.0],
        "clusters_x": [610.1383391401181, 1396.512905737758],
        "clusters_y": [391.8689431145336, 388.5538903107793],
        "line_slope": -0.221176437611867,
        "slope_label": 0,
        "gutter_label": 0,
        "number_views": 3,
        "clusters_text": [
          ["Moses,", "Moses,", "Moses,"],
          ["a", "a", "a"],
          ["small", "small", "small"],
          ["black", "black", "black"],
          ["man", "man", "man"],
          ["who", "who", "who"],
          ["has", "he", "has"]
        ],
        "extract_index": [4, 0, 0],
        "gold_standard": [false, false, false],
        "low_consensus": true,
        "consensus_text": "Moses, a small black man who has",
        "consensus_score": 2.857142857142857
      }, {
        "user_ids": [1325889.0],
        "clusters_x": [588.4872830039322, 1389.1773296798501],
        "clusters_y": [431.47057416528503, 433.9456593172971],
        "line_slope": -0.221176437611867,
        "slope_label": 0,
        "gutter_label": 0,
        "number_views": 1,
        "clusters_text": [
          ["been"],
          ["runaway"],
          ["for"],
          ["some"],
          ["months"],
          ["was"]
        ],
        "extract_index": [5],
        "gold_standard": [false],
        "low_consensus": true,
        "consensus_text": "been runaway for some months was",
        "consensus_score": 1.0
      }, {
        "user_ids": [1325889.0],
        "clusters_x": [595.9125384599686, 1391.6524148318622],
        "clusters_y": [474.78456432549694, 477.2596494775091],
        "line_slope": -0.221176437611867,
        "slope_label": 0,
        "gutter_label": 0,
        "number_views": 1,
        "clusters_text": [
          ["lodged"],
          ["in"],
          ["the"],
          ["workhouse"],
          ["or"],
          ["at"],
          ["least"]
        ],
        "extract_index": [6],
        "gold_standard": [false],
        "low_consensus": true,
        "consensus_text": "lodged in the workhouse or at least",
        "consensus_score": 1.0
      }, {
        "user_ids": [1325361.0],
        "clusters_x": [1114.2187434541593, 1339.3248982901018],
        "clusters_y": [534.9570468158536, 528.6456592970889],
        "line_slope": -0.221176437611867,
        "slope_label": 0,
        "gutter_label": 0,
        "number_views": 1,
        "clusters_text": [
          ["yesterday"]
        ],
        "extract_index": [0],
        "gold_standard": [false],
        "low_consensus": true,
        "consensus_text": "yesterday",
        "consensus_score": 1.0
      }, {
        "user_ids": [1325361.0],
        "clusters_x": [604.8309959169183, 1369.359666252441],
        "clusters_y": [601.722350434937, 599.9808272678856],
        "line_slope": -0.221176437611867,
        "slope_label": 0,
        "gutter_label": 0,
        "number_views": 1,
        "clusters_text": [
          ["having"],
          ["made"],
          ["up"],
          ["my"],
          ["mind"],
          ["to"],
          ["sell"],
          ["him"]
        ],
        "extract_index": [0],
        "gold_standard": [false],
        "low_consensus": true,
        "consensus_text": "having made up my mind to sell him",
        "consensus_score": 1.0
      }, {
        "user_ids": [1325361.0, 1325361.0],
        "clusters_x": [998.5099722768056, 1164.7098436042772],
        "clusters_y": [652.7696138327956, 648.562022153619],
        "line_slope": -0.221176437611867,
        "slope_label": 0,
        "gutter_label": 0,
        "number_views": 2,
        "clusters_text": [
          ["same", "same"]
        ],
        "extract_index": [1, 0],
        "gold_standard": [false, false],
        "low_consensus": true,
        "consensus_text": "same",
        "consensus_score": 2.0
      }, {
        "user_ids": [1325361.0],
        "clusters_x": [853.6358695652174, 948.4184782608695],
        "clusters_y": [684.1290760869565, 691.5339673913044],
        "line_slope": -0.221176437611867,
        "slope_label": 0,
        "gutter_label": 0,
        "number_views": 1,
        "clusters_text": [
          ["delay"]
        ],
        "extract_index": [0],
        "gold_standard": [false],
        "low_consensus": true,
        "consensus_text": "delay",
        "consensus_score": 1.0
      }, {
        "user_ids": [1325361.0, 1325361.0],
        "clusters_x": [871.3144654088051, 1139.8155136268344],
        "clusters_y": [736.6572327044025, 730.9444444444445],
        "line_slope": -0.221176437611867,
        "slope_label": 0,
        "gutter_label": 0,
        "number_views": 2,
        "clusters_text": [
          ["not", "not"],
          ["sell", "sell"],
          ["him", "him"]
        ],
        "extract_index": [0, 1],
        "gold_standard": [false, false],
        "low_consensus": true,
        "consensus_text": "not sell him",
        "consensus_score": 2.0
      }, {
        "user_ids": [55],
        "clusters_x": [1373.712918660287, 1254.8038277511962],
        "clusters_y": [653.555023923445, 641.0382775119617],
        "line_slope": -173.9909940425054,
        "slope_label": 2,
        "gutter_label": 0,
        "number_views": 1,
        "clusters_text": [
          ["What"],
          ["what?"]
        ],
        "extract_index": [2],
        "gold_standard": [false],
        "low_consensus": true,
        "consensus_text": "What what?",
        "consensus_score": 1.0
      }],
      "frame1": [{
        "user_ids": [1857.0, 1857.0],
        "clusters_x": [874.9671737389912, 1206.417934347478],
        "clusters_y": [55.59727782225781, 123.14411529223378],
        "line_slope": 11.518659344879472,
        "slope_label": 1,
        "gutter_label": 0,
        "number_views": 2,
        "clusters_text": [],
        "extract_index": [0, 0],
        "gold_standard": [false, false],
        "low_consensus": true,
        "consensus_text": "",
        "consensus_score": 0.0
      }, {
        "user_ids": [1325796.0, 1325796.0],
        "clusters_x": [921.6460722404647, 1315.224450618843],
        "clusters_y": [265.9831649406416, 265.9831649406416],
        "line_slope": -0.000000000000004174735093328781,
        "slope_label": 0,
        "gutter_label": 0,
        "number_views": 2,
        "clusters_text": [
          ["your", "yours"],
          ["respectfully", "respectfully"]
        ],
        "extract_index": [0, 0],
        "gold_standard": [false, false],
        "low_consensus": true,
        "consensus_text": "your respectfully",
        "consensus_score": 1.5
      }],
      "transcribed_lines": 18,
      "aggregation_version": "3.3.0",
      "low_consensus_lines": 15
    } }
  end
end
