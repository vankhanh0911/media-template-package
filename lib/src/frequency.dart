import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Frequency {
  static const String keyFreqCapping = 'at_freq_capping';
  static const String keyFreqCappingDestination = 'at_freq_capping_destination';
  static const String keyFreqCappingZone = 'at_freq_capping_zone';

  static Future<Map<String, dynamic>> getFrequency() async {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;

    final now = DateTime.now();

    Map<String, dynamic> freqCapping = {};
    Map<String, dynamic> freqCappingDestination = {};
    Map<String, dynamic> freqCappingZone = {};

    String? freq = prefs.getString(keyFreqCapping);
    String? freqDestination = prefs.getString(keyFreqCappingDestination);
    String? freqZone = prefs.getString(keyFreqCappingZone);

    if (freq != null && freq.isNotEmpty) {
      freqCapping = json.decode(freq) as Map<String, dynamic>;
      var keyRemove = [];

      freqCapping.forEach((key, value) {
        Map<String, dynamic> values = value;

        if (values['timeExpire'] != null &&
            values['timeExpire']! <= now.microsecondsSinceEpoch) {
          keyRemove.add(key);
        } else if (values['timeExpire'] == null) {
          keyRemove.add(key);
        }
      });

      keyRemove.isNotEmpty ? keyRemove.map((e) => freqCapping.remove(e)) : null;
    }

    if (freqDestination != null && freqDestination.isNotEmpty) {
      freqCappingDestination =
          json.decode(freqDestination) as Map<String, dynamic>;

      var keyRemove = [];

      freqCappingDestination.forEach((key, value) {
        Map<String, dynamic> values = value;

        if (values['timeExpire'] != null &&
            values['timeExpire'] <= now.microsecondsSinceEpoch) {
          keyRemove.add(key);
        } else if (values['timeExpire'] == null) {
          keyRemove.add(key);
        }
      });

      keyRemove.isNotEmpty
          ? keyRemove.map((e) => freqCappingDestination.remove(e))
          : null;
    }

    if (freqZone != null && freqZone.isNotEmpty) {
      freqCappingZone = json.decode(freqZone) as Map<String, dynamic>;
      var keyRemove = [];
      freqCappingZone.forEach((key, value) {
        Map<String, dynamic> values = value;

        if (values['timeExpire'] != null &&
            values['timeExpire'] <= now.microsecondsSinceEpoch) {
          keyRemove.add(key);
        } else if (values['timeExpire'] == null) {
          keyRemove.add(key);
        }
      });

      keyRemove.isNotEmpty
          ? keyRemove.map((e) => freqCappingZone.remove(e))
          : null;
    }

    return {
      "story": freqCapping,
      "destination": freqCappingDestination,
      "zone": freqCappingZone,
    };
  }

  static int getTimeExpire(String timeunit) {
    final now = DateTime.now();
    dynamic endTime;

    if (timeunit == 'daily') {
      endTime = DateTime(now.year, now.month, now.day, 23, 59, 59);
    } else if (timeunit == 'hourly') {
      endTime = DateTime(now.year, now.month, now.day, now.hour, 59, 59);
    } else if (timeunit == 'weekly') {
      endTime = DateTime(
          now.year, now.month, now.day + (7 - now.day) % 7, 23, 59, 59);
    } else if (timeunit == 'monthly') {
      endTime = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    } else if (timeunit == 'yearly') {
      endTime = DateTime(now.year, 12, 31, 23, 59, 59);
    }

    if (endTime != null) {
      return (endTime as DateTime).microsecondsSinceEpoch;
    }

    return 0;
  }

  static Future<void> processIncreaseFreq(
    num storyId,
    num destinationId,
    num zoneId,
    String type,
    Map<String, dynamic> frequencyCapping,
    Map<String, dynamic> destinationFrequencyCapping,
    Map<String, dynamic> zoneFrequencyCapping,
  ) async {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

    final SharedPreferences prefs = await _prefs;
    Map<String, dynamic> freq = await getFrequency();

    // process cached info freq
    Map<String, dynamic> storyFreq = freq['story'];
    Map<String, dynamic> zoneFreq = freq['zone'];
    Map<String, dynamic> destinationFreq = freq['destination'];

    if (frequencyCapping.isNotEmpty &&
        frequencyCapping.containsKey('timeUnit')) {
      Map<String, dynamic> story;
      if (storyFreq.isNotEmpty && storyFreq.containsKey(storyId.toString())) {
        story = storyFreq[storyId.toString()];
      } else {
        story = {type: 0};
      }

      int timeExpire = getTimeExpire(frequencyCapping['timeUnit']);

      num metric = 0;
      if (story.containsKey(type)) {
        metric = story[type];
      }

      if (metric > 0) {
        metric += 1;
      } else {
        metric = 1;
      }

      story[type] = metric;
      story['timeExpire'] = timeExpire;
      storyFreq[storyId.toString()] = story;

      prefs.setString(keyFreqCapping, jsonEncode(storyFreq));
    }

    if (zoneFrequencyCapping.isNotEmpty &&
        zoneFrequencyCapping.containsKey('timeUnit')) {
      Map<String, dynamic> zone;
      if (zoneFreq.containsKey(zoneId)) {
        zone = zoneFreq[storyId.toString()]!;
      } else {
        zone = {type: 0};
      }

      num metricZone = 0;
      if (zone.containsKey(type)) {
        metricZone = zone[type];
      }

      if (metricZone > 0) {
        metricZone += 1;
      } else {
        metricZone = 1;
      }

      int timeExpire = getTimeExpire(zoneFrequencyCapping['timeUnit']);

      zone[type] = metricZone;
      zone['timeExpire'] = timeExpire;
      zoneFreq[zoneId.toString()] = zone;
      prefs.setString(keyFreqCappingZone, jsonEncode(zoneFreq));
    }

    if (destinationFrequencyCapping.isNotEmpty &&
        destinationFrequencyCapping.containsKey('timeUnit')) {
      Map<String, dynamic> destination;
      if (destinationFreq.containsKey(destinationId)) {
        destination = destinationFreq[destinationId.toString()]!;
      } else {
        destination = {type: 0};
      }

      num metricDest = 0;
      if (destination.containsKey(type)) {
        metricDest = destination[type];
      }

      if (metricDest > 0) {
        metricDest += 1;
      } else {
        metricDest = 1;
      }

      int timeExpire = getTimeExpire(destinationFrequencyCapping['timeUnit']);

      destination[type] = metricDest;
      destination['timeExpire'] = timeExpire;
      destinationFreq[destinationId.toString()] = destination;
      prefs.setString(keyFreqCappingDestination, jsonEncode(destinationFreq));
    }
  }
}
