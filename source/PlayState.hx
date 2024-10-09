package;

import flixel.addons.ui.FlxUICheckBox;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.addons.ui.FlxUIInputText;
import haxe.Http;
import haxe.Json;
import flixel.FlxState;

using StringTools;

class PlayState extends FlxState
{
	// search handler
	var searchBar:FlxUIInputText;
	var youtubeSearch:FlxUICheckBox;

	// other
	var resultsText:Array<Dynamic> = [];
	var resultsDescriptionText:Array<Dynamic> = [];
	var resultsLinks:Array<String> = [];

	override public function create()
	{
		super.create();

		searchBar = new FlxUIInputText();
		searchBar.screenCenter();
		add(searchBar);

		youtubeSearch = new FlxUICheckBox(searchBar.x, searchBar.y + 25, null, null, "Search Using Youtube API");
		//add(youtubeSearch);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ENTER && searchBar.hasFocus)
		{
			for (loopLol in 0...resultsText.length + 1)
			{
				for (oldResult in resultsText)
					oldResult.destroy();

				for (oldDesc in resultsDescriptionText)
					oldDesc.destroy();
			}

			resultsText = [];
			resultsDescriptionText = [];
			resultsLinks = [];

			if (youtubeSearch.checked)
				searchYoutubeDatabase();
			else
				searchKittyDatabase();
		}

		for (i => search in resultsText) {
			search.alpha = 0.45;

			if (FlxG.mouse.overlaps(search)) {
				search.alpha = 1;

				if (FlxG.mouse.justPressed)
					FlxG.openURL(resultsLinks[i]);
			}
		}
	}

	function searchKittyDatabase()
	{
		var database:Dynamic;
		var resultIndex:Int = -1;

		var data = new Http("https://raw.githubusercontent.com/KittySleeper/kitty-browser/refs/heads/main/database.json");
		data.onData = function(rawdata)
		{
			database = Json.parse(rawdata);
		}
		data.onError = function(e)
		{
			trace(e);
		}
		data.request();

		var searchData:Array<Dynamic> = database.searchData;

		for (result in searchData)
		{			
			if (StringTools.contains(result.name.toLowerCase(), searchBar.text.toLowerCase()) || result.tags.contains(searchBar.text.toLowerCase()))
			{
				resultIndex++;

				var text = new FlxText(0, resultIndex * 50, 0, result.name);
				text.setFormat("assets/defaultfont.ttf", 25);
				resultsLinks.push(result.link);
				resultsText.push(text);
				add(text);

				var desctext = new FlxText(0, text.y + 28, 0, result.description);
				desctext.setFormat("assets/defaultfont.ttf", 19);
				resultsDescriptionText.push(desctext);
				add(desctext);
			}
		}
	}

	function searchYoutubeDatabase()
	{			
		var database:Dynamic;

		var ytdata = new Http("https://www.googleapis.com/youtube/v3/search?part=snippet&q="
			+ searchBar.text.replace(" ", "+")
			+ "&maxResults=10&key=AIzaSyCq6OhnSOVIi_LoSu3rQxdThVcTlej1zTY");
		ytdata.onData = function(rawdata:Dynamic)
		{
			database = Json.parse(rawdata);
		}
		ytdata.onError = function(e)
		{
			trace(e);
		}
		trace(ytdata.url);
		ytdata.request();

		var searchData:Array<Dynamic> = database.items;

		for (i => result in searchData)
		{
			var text = new FlxText(0, (i * 45), 0, result.snippet.title);
			text.setFormat("assets/defaultfont.ttf", 25);
			resultsLinks.push("https://www.youtube.com/watch?v=" + result.id.videoId);
			resultsText.push(text);
			text.ID = i;
			add(text);
		}
	}
}