/**
 * Bacterial Reference Annotation Genome Viewer
 @namespace BRAGV
*/
var BRAGV = {};

var debug = true;

/**
 * The viewer object that contains all the elements of BRAGV
 * @param {string} divName
 */
BRAGV.Viewer = function(divName)
{
	this.offset = 0;
	this.numBases = 1000;
	
	this.start = 0;
	this.end = 0;
	
	this.tracks = {};
	
	div = $(document.getElementById(divName));
	
	var w = div.innerWidth();
	var h = 400;
	
	div.append('<canvas id='+ divName + '_Viewer width="'+w+'" height="'+h+'"></canvas>');
	
	ctx = $('canvas', div)[0].getContext('2d');
	
	this.baseWidth = this.numBases / (w - 40.0);
	this.trackWidth = w - 40;
	
	if(debug)
	{
		this.tracks["track1"] = new BRAGV.Track();
		this.tracks["track2"] = new BRAGV.Track();
		this.tracks["track3"] = new BRAGV.Track();
		this.tracks["track4"] = new BRAGV.Track();
		this.tracks["track5"] = new BRAGV.Track();
		this.tracks["track6"] = new BRAGV.Track();
	}
	
	this.drawTicks();
	this.drawTracks(w);
};

BRAGV.Viewer.prototype = {
		drawTicks : function()
		{
			var start = 40;
			var end = this.trackWidth + 39;
			
			ctx.beginPath();
			ctx.moveTo(start, 10);
			ctx.lineTo(start, 20);
			ctx.stroke();
			
			ctx.beginPath();
			ctx.moveTo(end, 10);
			ctx.lineTo(end, 20);
			ctx.stroke();
			
			var txt = (this.offset).toString();
			var wt = ctx.measureText(txt).width;
			ctx.fillText(this.offset, start-wt, 10);
			var txt = (this.offset + this.numBases).toString();
			var wt = ctx.measureText(txt).width;
			ctx.fillText(txt, end-wt, 10);
		},
		drawTracks : function(w)
		{
			var i = 1;
			var trackheight = 20;
			var padding = 3;
			
			
			for(var t in this.tracks)
			{
				var tracky  = i*(trackheight + padding);
				ctx.fillStyle = 'rgba(80, 80, 80, 0.1)';
				ctx.fillRect(40, tracky, w - 40, trackheight);
				ctx.fillStyle = 'rgba(0, 0, 0, 1)';
				ctx.fillText(t, 5, ++i * (trackheight +	 padding) -10);
				
				var features = this.tracks[t].features;
				var count = features.length;
				
				for(var j = count; j--; )
				{
					if(debug){
						console.debug('drawing ' + features[j].i);
						console.debug((40 + (features[j].s * this.baseWidth)));
						console.debug(tracky);
						console.debug( (features[j].e - features[j].s) * this.baseWidth);
					}
					
					ctx.fillStyle = 'rgba(255, 0, 0, 1)';
					ctx.fillRect(40 + (features[j].s * this.baseWidth), tracky, 40 + ((features[j].e - features[j].s)) * this.baseWidth, trackheight);
				}
			}
		}
};

/**
 * 
 * @param {string} trackName the name of this track
 */
BRAGV.Track = function(trackName)
{
	this.features = [];
	
	if(debug) {
		function genPos(min, max)
		{
			return max * Math.random() + min;
		}
		
		var s = genPos(1, 1000);
		var e = genPos(s+1, 1000);
		
		this.features = [{
			s: s,
			e: e,
			n: 'ABC',
			i: 'DEF'
		}];
	}
};

