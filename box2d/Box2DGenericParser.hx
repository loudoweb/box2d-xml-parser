package box2d;

import haxe.xml.Access;

enum EFixtureType {
	POLYGON;
	CIRCLE;
}

typedef Circle = {r:Float, x:Float, y:Float}
typedef Fixture = {density:Float, friction:Float, restitution:Float, fixtureType:EFixtureType, ?polygons:Array<Array<Float>>, ?circle:Circle}
typedef Body = {name:String, anchorX:Float, anchorY:Float, fixture:Array<Fixture>}

/**
 * This parser allows to get data from Box2d XML (exported with PhysicsEditor by CodeAndWeb)
 * It's a generic parser because it doesn't convert data to internal box2d classes.
 * @author Ludovic Bas - www.lugludum.com
 */
class Box2DGenericParser {
	static var spaces:EReg = new EReg(" ", "g");

	/**
	 * 
	 * @param	xml_string the parser convert automatically in xml so just set the string here.
	 * @param	invertY you may need to invert y in the anchorpoint (default: true = bottom to top y)
	 * @param	trimmer(assetName:String, isX:Bool) allow to use trim values with your own method (can help to simplify your code if you use an atlas with trimmed transparency)
	 * @return
	 */
	public static function parse(xml_string:String, invertY:Bool = true, ?trimmer:String->Bool->Float):Array<Body> {
		var xml:Xml = Xml.parse(xml_string).firstElement();
		var fast:Access = new Access(xml);

		var bodies:Array<Body> = [];
		for (body in fast.node.bodies.nodes.body) {
			var anchor = body.node.anchorpoint.innerData.split(",");
			var name = body.att.name;

			var _body = {
				name: name,
				anchorX: Std.parseFloat(anchor[0]),
				anchorY: invertY ? (1 - Std.parseFloat(anchor[1])) : Std.parseFloat(anchor[1]),
				fixture: null
			};

			var fixtures:Array<Fixture> = [];

			for (fixture in body.node.fixtures.nodes.fixture) {
				var type = Type.createEnum(EFixtureType, fixture.node.fixture_type.innerData);

				var polygons:Array<Array<Float>> = null;
				var circle:Circle = null;

				if (type == POLYGON) {
					polygons = [];
					for (polygon in fixture.node.polygons.nodes.polygon) {
						var t = spaces.replace(polygon.innerData, "");

						var _polygon:Array<Float> = t.split(',').map(function(s) return Std.parseFloat(s));

						if (trimmer != null) {
							for (i in 0..._polygon.length) {
								_polygon[i] += trimmer(name, i % 2 == 0);
								if (i % 2 == 1) {
									_polygon[i] = -_polygon[i];
								}
							}
						} else if (invertY) {
							for (i in 0..._polygon.length) {
								if (i % 2 == 1) {
									_polygon[i] = -_polygon[i];
								}
							}
						}
						polygons.push(_polygon);
					}
				} else {
					var _circle = fixture.node.circle;
					circle = {
						r: Std.parseFloat(_circle.att.r),
						x: Std.parseFloat(_circle.att.x),
						y: invertY ? -Std.parseFloat(_circle.att.y) : Std.parseFloat(_circle.att.y)
					};
				}

				var _fixture:Fixture = {
					density: Std.parseFloat(fixture.node.density.innerData),
					friction: Std.parseFloat(fixture.node.friction.innerData),
					restitution: Std.parseFloat(fixture.node.restitution.innerData),
					fixtureType: type,
					polygons: polygons,
					circle: circle
				};
				fixtures.push(_fixture);
			}
			_body.fixture = fixtures;
			bodies.push(_body);
		}
		return bodies;
	}
}
