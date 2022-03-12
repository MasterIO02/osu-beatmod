package src;

import sys.FileSystem;
import Std.isOfType;
import sys.io.File;
import Std.parseInt;
import Std.parseFloat;
import hx.strings.Strings.isBlank;

function writeBeatmap(beatmapFilePath:String, beatmapFolderPath:String, newAudioFilename:String, targetBPM:Float, speedMultiplier:Float, hp, cs, od, ar) {
	var beatmapFile = File.getContent(beatmapFilePath);
	var beatmapLines = beatmapFile.split("\n");

	var newBeatmapFile = [];

	var version = '$targetBPM bpm';
	if (hp != "None")
		version += ' HP $hp';
	if (cs != "None")
		version += ' CS $cs';
	if (od != "None")
		version += ' OD $od';
	if (ar != "None")
		version += ' AR $ar';

	// that parser/writer is probably ugly. maybe should make a good one from scratch. at least it's fast I guess.

	var inBreaks = false;
	var inTimingPoints = false;
	var inHitObjects = false;

	for (line in beatmapLines) {
		// if we're in a section where there's break points
		if (inBreaks && !StringTools.contains(line, "//")) {
			var breakInfo = line.split(",");
			var newBreakStartTime = Math.round(parseInt(breakInfo[1]) / speedMultiplier);
			var newBreakEndTime = Math.round(parseInt(breakInfo[2]) / speedMultiplier);
			line = '${breakInfo[0]},${newBreakStartTime},${newBreakEndTime}';
			newBeatmapFile.push(line);
			continue;
		} else {
			inBreaks = false;
		}
		if (StringTools.contains(line, "Break Periods")) {
			inBreaks = true;
		}

		if (inTimingPoints && !StringTools.contains(line, "[")) {
			if (isBlank(line))
				continue;

			var timingPointInfo = line.split(",");
			if (isOfType(timingPointInfo[0], null))
				continue;
			var newTime = Std.int(parseFloat(timingPointInfo[0]) / speedMultiplier);

			var beatLength = parseInt(timingPointInfo[1]);
			var newBeatLength = beatLength > 0 ? beatLength / speedMultiplier : beatLength;

			line = '${newTime},${newBeatLength},${timingPointInfo[2]},${timingPointInfo[3]},${timingPointInfo[4]},${timingPointInfo[5]},${timingPointInfo[6]},${timingPointInfo[7]}';
			newBeatmapFile.push(line);
			continue;
		} else {
			inTimingPoints = false;
		}
		if (StringTools.contains(line, "TimingPoints")) {
			inTimingPoints = true;
		}

		if (inHitObjects && !StringTools.contains(line, "[")) {
			if (isBlank(line))
				continue;
			var hitObjectInfo = line.split(",");
			var isSpinner = parseInt(hitObjectInfo[3]) & 1 << 3 != 0;

			var newObjectStartTime = Math.round(Std.parseFloat(hitObjectInfo[2]) / speedMultiplier);

			var rest = "";
			var currentIteration = 0;
			for (part in hitObjectInfo) {
				currentIteration++;
				var iterationCount = isSpinner ? 7 : 4;
				if (currentIteration >= iterationCount) {
					rest += ',$part';
				}
			}

			if (isSpinner) {
				var newSpinnerEndTime = Math.round(Std.parseFloat(hitObjectInfo[5]) / speedMultiplier);
				line = '${hitObjectInfo[0]},${hitObjectInfo[1]},${newObjectStartTime},${hitObjectInfo[3]},${hitObjectInfo[4]},${newSpinnerEndTime}$rest';

				newBeatmapFile.push(line);
				continue;
			}

			line = '${hitObjectInfo[0]},${hitObjectInfo[1]},${newObjectStartTime}$rest';
			newBeatmapFile.push(line);
			continue;
		} else {
			inHitObjects = false;
		}
		if (StringTools.contains(line, "HitObjects")) {
			inHitObjects = true;
		}

		if (StringTools.contains(line, "AudioFilename")) {
			line = 'AudioFilename: $newAudioFilename';
		}

		if (StringTools.contains(line, "Version")) {
			line = '${StringTools.rtrim(line)} ($version)';
		}

		if (StringTools.contains(line, "HPDrainRate") && hp != "None") {
			line = 'HPDrainRate:$hp';
		}

		if (StringTools.contains(line, "CircleSize") && cs != "None") {
			line = 'CircleSize:$cs';
		}

		if (StringTools.contains(line, "OverallDifficulty") && od != "None") {
			line = 'OverallDifficulty:$od';
		}

		if (StringTools.contains(line, "ApproachRate") && ar != "None") {
			line = 'ApproachRate:$ar';
		}

		newBeatmapFile.push(line);
	}

	var newBeatmapFilePath = beatmapFilePath.split("].osu")[0] + ' ($version)].osu';
	var finishedBeatmapFile = "";
	for (line in newBeatmapFile) {
		finishedBeatmapFile += line + "\n";
	}

	File.saveContent(newBeatmapFilePath, finishedBeatmapFile);

	// trigger osu new change detected
	FileSystem.rename(beatmapFolderPath, beatmapFolderPath + "a");
	FileSystem.rename(beatmapFolderPath + "a", beatmapFolderPath);
}
