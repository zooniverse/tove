FactoryBot.define do
  factory :transcription do
    workflow
    group_id { 'GROUP1A' }
    text { { 'checkout_this': 'metadata' } }
    status { 1 }
  end

  trait :unedited_json_blob do
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
        "consensus_score": 1.0,
        "edited_consensus_text": ""
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

  trait :edited_json_blob do
    text {
      {
        "frame0": [{
          "seen": false,
          "flagged": false,
          "user_ids": [1325796, 1325796, 1325361],
          "clusters_x": [904.8769647573996, 604.9414062892324],
          "clusters_y": [268.05475082105517, 269.75898766659634],
          "line_slope": 179.67665775917354,
          "line_editor": "wgranger-test",
          "slope_label": 1,
          "gutter_label": 0,
          "number_views": 3,
          "clusters_text": [
            ["Ms", "z", ""],
            ["Z", "b", ""],
            ["B", "", ""],
            ["Oakes", "oakes", "oakes"]
          ],
          "extract_index": [0, 0, 0],
          "gold_standard": [false, false, false],
          "low_consensus": true,
          "consensus_text": "Ms Z B oakes",
          "consensus_score": 1.25,
          "edited_consensus_text": "Ms. Z B Oakes"
        }, {
          "seen": false,
          "flagged": false,
          "user_ids": [1325796, 27],
          "clusters_x": [1069.5852842809365, 797.267558528428],
          "clusters_y": [74.433110367893, 146.61371237458195],
          "line_slope": 165.15454791791615,
          "line_editor": "",
          "slope_label": 2,
          "gutter_label": 0,
          "number_views": 2,
          "clusters_text": [
            ["john", "john"],
            ["leland", "leland"]
          ],
          "extract_index": [0, 0],
          "gold_standard": [false, false],
          "low_consensus": true,
          "consensus_text": "john leland",
          "consensus_score": 2,
          "edited_consensus_text": ""
        }, {
          "seen": false,
          "flagged": false,
          "user_ids": [1325796, 1325796, 1325796, 11, 22],
          "clusters_x": [788.6663088447522, 1396.2876008804108],
          "clusters_y": [137.53115373432394, 136.10051357300074],
          "line_slope": -0.1268525161618382,
          "line_editor": "",
          "slope_label": 0,
          "gutter_label": 0,
          "number_views": 5,
          "clusters_text": [
            ["John", "John", "John", "John's", "John's"],
            ["Leland", "Leland", "Leland", "leland", "leland"]
          ],
          "extract_index": [1, 1, 0, 0, 0],
          "gold_standard": [false, false, false, false, false],
          "low_consensus": false,
          "consensus_text": "John Leland",
          "consensus_score": 3,
          "edited_consensus_text": ""
        }, {
          "seen": false,
          "flagged": false,
          "user_ids": [1325796, 1325796, 1325796, 1325796, 1325841, 1325361, 1325361, 1325361],
          "clusters_x": [605.631423708881, 920.2989360994401],
          "clusters_y": [259.49853208997695, 263.41288611118017],
          "line_slope": -0.1268525161618382,
          "line_editor": "",
          "slope_label": 0,
          "gutter_label": 0,
          "number_views": 8,
          "clusters_text": [
            ["Ms.", "Ms.", "Mrs.", "", "", "mr", "Mr", ""],
            ["Le", "Z", "Z", "", "", "L", "L", "Hey"],
            ["B", "B", "b", "", "", "B", "B", "B"],
            ["Oakes", "Oakes", "oak", "oakes", "oakes", "Oakes", "Oakes", "Oakes"]
          ],
          "extract_index": [0, 0, 0, 0, 0, 0, 0, 0],
          "gold_standard": [false, false, false, false, false, false, false, false],
          "low_consensus": false,
          "consensus_text": "Ms. Z B Oakes",
          "consensus_score": 3.5,
          "edited_consensus_text": ""
        }, {
          "seen": false,
          "flagged": false,
          "user_ids": [1325361, 1325361, 1325801, 1325361, 1325361, 1325361],
          "clusters_x": [662.6512726948562, 1386.1038558200314],
          "clusters_y": [301.13431416166986, 297.049147479391],
          "line_slope": -0.1268525161618382,
          "line_editor": "",
          "slope_label": 0,
          "gutter_label": 0,
          "number_views": 6,
          "clusters_text": [
            ["DEAR", "dear", "DEAR", "DEAR", "dear", "dear"],
            ["SIR", "sir", "SIR", "SIR", "sir", "sir"],
            ["I", "i", "I", "I", "I", ""],
            ["HAVE", "have", "HAVE", "HAVE", "have", ""],
            ["JUST", "receive", "JUST", "JUST", "just", ""],
            ["RECEIVED", "(darke_shard)", "RECEIVED", "RECEIVED", "received", ""]
          ],
          "extract_index": [0, 0, 0, 0, 1, 1],
          "gold_standard": [false, false, false, false, false, false],
          "low_consensus": false,
          "consensus_text": "DEAR SIR I HAVE JUST RECEIVED",
          "consensus_score": 3.1666666666666665,
          "edited_consensus_text": ""
        }, {
          "seen": false,
          "flagged": false,
          "user_ids": [1325800, 1325802, 1325801, 1325801, 1325361, 1325796],
          "clusters_x": [588.9575803040453, 1355.340192373983],
          "clusters_y": [345.36075208531184, 340.930257316186],
          "line_slope": -0.1268525161618382,
          "line_editor": "",
          "slope_label": 0,
          "gutter_label": 0,
          "number_views": 6,
          "clusters_text": [
            ["information", "information", "ingformation", "ingformation", "INFORMATION", "information"],
            ["that", "that", "that", "that", "THAT", "that"],
            ["a", "a", "a", "a", "A", "a"],
            ["fellow", "fellow", "fellow", "fellow", "FELLOW", "fellow"],
            ["of", "of", "of", "of", "OF", "of"],
            ["mine", "miine", "minne", "mine", "MINE", "mine"]
          ],
          "extract_index": [0, 0, 0, 0, 1, 0],
          "gold_standard": [false, false, false, false, false, false],
          "low_consensus": false,
          "consensus_text": "information that a fellow of mine",
          "consensus_score": 4.333333333333333,
          "edited_consensus_text": ""
        }, {
          "seen": false,
          "flagged": false,
          "user_ids": [1325796, 1325803, 1325361, 1325801],
          "clusters_x": [595.8977254030042, 1392.7806128888283],
          "clusters_y": [394.716147523171, 384.3310097842535],
          "line_slope": -0.1268525161618382,
          "line_editor": "",
          "slope_label": 0,
          "gutter_label": 0,
          "number_views": 4,
          "clusters_text": [
            ["Moses,", "Moses,", "Moses", "Moses"],
            ["a", "a", "a", "a"],
            ["small", "small", "small", "small"],
            ["black", "black", "black", "black"],
            ["man", "man", "man", "man"],
            ["who", "who", "who", "who"],
            ["has", "has", "has", "has"]
          ],
          "extract_index": [1, 1, 0, 0],
          "gold_standard": [false, false, false, false],
          "low_consensus": false,
          "consensus_text": "Moses, a small black man who has",
          "consensus_score": 3.7142857142857144,
          "edited_consensus_text": ""
        }, {
          "seen": false,
          "flagged": false,
          "user_ids": [1325796, 1325796],
          "clusters_x": [590.5723467369809, 1387.5944297956494],
          "clusters_y": [433.31608437706, 431.699406723797],
          "line_slope": -0.1268525161618382,
          "line_editor": "",
          "slope_label": 0,
          "gutter_label": 0,
          "number_views": 2,
          "clusters_text": [
            ["been", "been"],
            ["runaway", "runaway"],
            ["for", "for"],
            ["some", "some"],
            ["months", "months"],
            ["was", "was"]
          ],
          "extract_index": [2, 0],
          "gold_standard": [false, false],
          "low_consensus": true,
          "consensus_text": "been runaway for some months was",
          "consensus_score": 2,
          "edited_consensus_text": ""
        }, {
          "seen": false,
          "flagged": false,
          "user_ids": [27],
          "clusters_x": [800.7546230440967, 1054.2610241820769],
          "clusters_y": [203.86130867709818, 201.53556187766713],
          "line_slope": -0.1268525161618382,
          "line_editor": "",
          "slope_label": 0,
          "gutter_label": 0,
          "number_views": 1,
          "clusters_text": [
            ["???"],
            ["LOLS"]
          ],
          "extract_index": [1],
          "gold_standard": [false],
          "low_consensus": true,
          "consensus_text": "??? LOLS",
          "consensus_score": 1,
          "edited_consensus_text": ""
        }, {
          "seen": false,
          "flagged": false,
          "user_ids": [1325803],
          "clusters_x": [599.5662211421628, 1368.3936816524908],
          "clusters_y": [480.26063183475094, 481.7506075334143],
          "line_slope": -0.1268525161618382,
          "line_editor": "",
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
            ["here"]
          ],
          "extract_index": [0],
          "gold_standard": [false],
          "low_consensus": true,
          "consensus_text": "lodged in the workhouse or at here",
          "consensus_score": 1,
          "edited_consensus_text": ""
        }, {
          "seen": false,
          "flagged": false,
          "user_ids": [1325361],
          "clusters_x": [835.2366863905326, 1125.473372781065],
          "clusters_y": [509.32544378698225, 513.1952662721893],
          "line_slope": -0.1268525161618382,
          "line_editor": "",
          "slope_label": 0,
          "gutter_label": 0,
          "number_views": 1,
          "clusters_text": [
            ["by"],
            ["the"],
            ["police"]
          ],
          "extract_index": [0],
          "gold_standard": [false],
          "low_consensus": true,
          "consensus_text": "by the police",
          "consensus_score": 1,
          "edited_consensus_text": ""
        }, {
          "seen": false,
          "flagged": false,
          "user_ids": [1325361],
          "clusters_x": [856.5978260869565, 1092.0733695652175],
          "clusters_y": [556.7649456521739, 550.8410326086956],
          "line_slope": -0.1268525161618382,
          "line_editor": "",
          "slope_label": 0,
          "gutter_label": 0,
          "number_views": 1,
          "clusters_text": [
            ["last"],
            ["february"]
          ],
          "extract_index": [0],
          "gold_standard": [false],
          "low_consensus": true,
          "consensus_text": "last february",
          "consensus_score": 1,
          "edited_consensus_text": ""
        }, {
          "seen": false,
          "flagged": false,
          "user_ids": [1325796],
          "clusters_x": [603.8597464035054, 1390.4738066617551],
          "clusters_y": [608.713986583427, 610.2778316336422],
          "line_slope": -0.1268525161618382,
          "line_editor": "",
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
          "extract_index": [2],
          "gold_standard": [false],
          "low_consensus": true,
          "consensus_text": "having made up my mind to sell him",
          "consensus_score": 1,
          "edited_consensus_text": ""
        }, {
          "seen": false,
          "flagged": false,
          "user_ids": [1325361],
          "clusters_x": [858.0788043478261, 942.4945652173913],
          "clusters_y": [679.6861413043479, 676.7241847826087],
          "line_slope": -0.1268525161618382,
          "line_editor": "",
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
          "consensus_score": 1,
          "edited_consensus_text": ""
        }, {
          "seen": false,
          "flagged": false,
          "user_ids": [1325361],
          "clusters_x": [867.4852071005917, 1139.6627218934912],
          "clusters_y": [727.3254437869823, 729.905325443787],
          "line_slope": -0.1268525161618382,
          "line_editor": "",
          "slope_label": 0,
          "gutter_label": 0,
          "number_views": 1,
          "clusters_text": [
            ["not"],
            ["sell"],
            ["him"]
          ],
          "extract_index": [1],
          "gold_standard": [false],
          "low_consensus": true,
          "consensus_text": "not sell him",
          "consensus_score": 1,
          "edited_consensus_text": ""
        }],
        "frame1": [{
          "seen": false,
          "flagged": false,
          "user_ids": [1325361, 1325361],
          "clusters_x": [609.9423313524683, 1350.370071881662],
          "clusters_y": [76.34385268297919, 94.28916153641592],
          "line_slope": 0.7241649502254157,
          "line_editor": "",
          "slope_label": 0,
          "gutter_label": 0,
          "number_views": 2,
          "clusters_text": [
            ["by", "my"],
            ["mail", "mail"],
            ["signed", "signed"],
            ["smile", "while"],
            ["and", "and"],
            ["let", "let"],
            ["me", "me"]
          ],
          "extract_index": [0, 0],
          "gold_standard": [false, false],
          "low_consensus": true,
          "consensus_text": "by mail signed smile and let me",
          "consensus_score": 1.7142857142857142,
          "edited_consensus_text": ""
        }, {
          "seen": false,
          "flagged": false,
          "user_ids": [1325796],
          "clusters_x": [619.7719626168225, 1166.1981308411214],
          "clusters_y": [231.11775700934584, 223.78317757009347],
          "line_slope": 0.7241649502254157,
          "line_editor": "",
          "slope_label": 0,
          "gutter_label": 0,
          "number_views": 1,
          "clusters_text": [
            ["test"],
            ["this"],
            ["out"]
          ],
          "extract_index": [0],
          "gold_standard": [false],
          "low_consensus": true,
          "consensus_text": "test this out",
          "consensus_score": 1,
          "edited_consensus_text": ""
        }, {
          "seen": false,
          "flagged": false,
          "user_ids": [1325796],
          "clusters_x": [921.5738880918221, 1325.0459110473457],
          "clusters_y": [263.3113342898135, 269.5667144906743],
          "line_slope": 0.7241649502254157,
          "line_editor": "",
          "slope_label": 0,
          "gutter_label": 0,
          "number_views": 1,
          "clusters_text": [
            ["yours"],
            ["respectfully"]
          ],
          "extract_index": [0],
          "gold_standard": [false],
          "low_consensus": true,
          "consensus_text": "yours respectfully",
          "consensus_score": 1,
          "edited_consensus_text": ""
        }, {
          "seen": false,
          "flagged": false,
          "user_ids": [1325796],
          "clusters_x": [1148.3314203730272, 599.4218077474893],
          "clusters_y": [221.08751793400285, 219.52367288378764],
          "line_slope": -179.83676460258107,
          "line_editor": "",
          "slope_label": 1,
          "gutter_label": 0,
          "number_views": 1,
          "clusters_text": [
            ["to"],
            ["the"],
            ["workhouse"],
            ["master"]
          ],
          "extract_index": [1],
          "gold_standard": [false],
          "low_consensus": true,
          "consensus_text": "to the workhouse master",
          "consensus_score": 1,
          "edited_consensus_text": ""
        }],
        "transcribed_lines": 19,
        "low_consensus_lines": 14
      }
    }
  end
end
