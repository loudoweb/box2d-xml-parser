package box2d;
import haxe.xml.Access;


enum EFixtureType {
	POLYGON;
	CIRCLE;
}

typedef Circle = {r:Float, x:Float, y:Float}
typedef Fixture = {density:Int, friction:Int, restitution:Int, fixtureType:EFixtureType, ?polygons: Array<Array<Float>>, ?circle:Circle }
typedef Body = {name:String, anchorX:Float, anchorY:Float, fixture:Array<Fixture>}

/**
 * This parser allows to get data from Box2d XML (exported with PhysicsEditor by CodeAndWeb)
 * @author Ludovic Bas - www.lugludum.com
 */
class Box2DParser 
{
	static var spaces:EReg = new EReg(" ", "g");

	public static function parse(xml_string:String):Array<Body>
	{
		var xml:Xml = Xml.parse(xml_string).firstElement();
		var fast:Access = new Access(xml);
		
		var bodies:Array<Body> = [];
		for (body in fast.node.bodies.nodes.body)
		{
			var anchor = body.node.anchorpoint.innerData.split(",");
			var name = body.att.name;
			
			var _body = {
				name: name, 
				anchorX: Std.parseFloat(anchor[0]),
				anchorY: Std.parseFloat(anchor[1]),
				fixture: null
			};
			
			var fixtures:Array<Fixture> = [];
			
			for (fixture in body.node.fixtures.nodes.fixture)
			{
				var type = Type.createEnum(EFixtureType, fixture.node.fixture_type.innerData);
				
				
				var polygons:Array<Array<Float>> = null;
				var circle:Circle = null;
				
				if (type == POLYGON)
				{
					polygons = [];
					for (polygon in fixture.node.polygons.nodes.polygon)
					{
						var t = spaces.replace(polygon.innerData, "");
						var _polygon:Array<Float> =  t.split(',').map(function(s) return Std.parseFloat(s));
						polygons.push(_polygon);
					}
				}else{
					var _circle = fixture.node.circle;
					circle = {
						r: Std.parseFloat(_circle.att.r),
						x: Std.parseFloat(_circle.att.x),
						y: Std.parseFloat(_circle.att.y)
					};
				}
				
				var _fixture:Fixture = {
					density: Std.parseInt(fixture.node.density.innerData),
					friction: Std.parseInt(fixture.node.friction.innerData),
					restitution: Std.parseInt(fixture.node.restitution.innerData),
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