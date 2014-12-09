package botserver.client.message.structure;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonPrimitive;

public class JSONmessage {
	//{"move":{"token":"undefined","data":{"instruction":"UP","value":""}}}
	public static JsonObject messageMovement (String token, String instruction, String value){	
		JsonObject data = new JsonObject();
		JsonObject response = new JsonObject();
		JsonObject move = new JsonObject();
		
		data.add("instruction",new JsonPrimitive( instruction ) );
		data.add("value",new JsonPrimitive( value ) );
		
		move.add("token", new JsonPrimitive( token ) );
		move.add("data", data );
		
		response.add("move", move);
		
		return response;
		
		
	}
}
