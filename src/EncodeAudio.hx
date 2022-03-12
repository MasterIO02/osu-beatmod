package src;

import sys.FileSystem;
import sys.io.Process;

function encodeAudio(beatmapRootPath:String, audioFilename:String, targetBPM:Float, targetSpeed:Float) {
	var fileExtension;
	if (StringTools.contains(audioFilename.substr(audioFilename.length - 5), ".")) {
		fileExtension = audioFilename.substr(audioFilename.length - 4);
	} else {
		fileExtension = audioFilename.substr(audioFilename.length - 5);
	}

	final outputAudioFilename = '${audioFilename.substring(0, audioFilename.length - 5)}-${targetBPM}bpm.${fileExtension}';

	// if the modified audio file already exists we skip the encoding, useful for making multiple difficulties of same song but with different AR/OD/HP/CS
	if (FileSystem.exists('${beatmapRootPath}/${StringTools.rtrim(outputAudioFilename)}')) {
		Console.println("The modified audio file already exixts, skipping encoding.");
		return {fail: false, newAudioFilename: outputAudioFilename};
	}

	final audioPath = '${beatmapRootPath}/${audioFilename}';

	final ffmpegCommand = 'ffmpeg -y -i "${StringTools.rtrim(audioPath)}" -filter:a "atempo=$targetSpeed" -vn "${beatmapRootPath}/${StringTools.rtrim(outputAudioFilename)}"';
	final ffmpeg = new Process(ffmpegCommand);
	if (ffmpeg.exitCode() != 0) {
		Console.println('Error with ffmpeg: ${ffmpeg.stderr.readAll()}');
		return {fail: true, newAudioFilename: ""}
	}
	ffmpeg.close();
	return {fail: false, newAudioFilename: outputAudioFilename}
}
