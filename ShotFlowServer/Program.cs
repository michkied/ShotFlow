using System;
using System.Net;
using System.Net.WebSockets;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

class WebSocketServer
{
    public static async Task Start(string uriPrefix)
    {
        HttpListener listener = new HttpListener();
        listener.Prefixes.Add(uriPrefix);
        listener.Start();
        Console.WriteLine($"WebSocket server started at {uriPrefix}");

        while (true)
        {
            HttpListenerContext context = await listener.GetContextAsync();

            // Check if it is a WebSocket request
            if (context.Request.IsWebSocketRequest)
            {
                ProcessWebSocketConnection(context);
            }
            else
            {
                context.Response.StatusCode = 400; // Bad Request
                context.Response.Close();
            }
        }
    }

    private static async void ProcessWebSocketConnection(HttpListenerContext context)
    {
        WebSocket webSocket = (await context.AcceptWebSocketAsync(null)).WebSocket;
        Console.WriteLine("WebSocket connection established.");

        int i = 0;
        byte[] buffer = new byte[1024];
        WebSocketReceiveResult result;
        try
        {
            result = await webSocket.ReceiveAsync(new ArraySegment<byte>(buffer), CancellationToken.None);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error: {ex.Message}");
            webSocket.Dispose();
            return;
        }
        if (result.MessageType == WebSocketMessageType.Close)
        {
            Console.WriteLine("WebSocket connection closed.");
            await webSocket.CloseAsync(WebSocketCloseStatus.NormalClosure, "Closing", CancellationToken.None);
            webSocket.Dispose();
            return;
        }
        string receivedToken = Encoding.UTF8.GetString(buffer, 0, result.Count);
        string token = "abc";
        string responseMessage;
        byte[] responseBuffer;
        
        if (receivedToken != token)
        {
            Console.WriteLine($"Invalid token - {receivedToken}. Closing connection.");
            responseMessage = "invalid token";
            responseBuffer = Encoding.UTF8.GetBytes(responseMessage);
            await webSocket.SendAsync(new ArraySegment<byte>(responseBuffer), WebSocketMessageType.Text, true, CancellationToken.None);
            webSocket.Abort();
            webSocket.Dispose();
            return;
        }
        
        Thread.Sleep(1000);
        responseMessage = "ok";
        responseBuffer = Encoding.UTF8.GetBytes(responseMessage);
        await webSocket.SendAsync(new ArraySegment<byte>(responseBuffer), WebSocketMessageType.Text, true,
            CancellationToken.None);

        Console.WriteLine("Token verified. Connection established.");
        
        var data = new[]
        {
            new { id = 0, title = "Drums", operator_id = 1, operator_name = "Alice", duration = 5 },
            new { id = 1, title = "Violin", operator_id = 2, operator_name = "Bob", duration = 4 },
            new { id = 2, title = "Flute", operator_id = 3, operator_name = "Charlie", duration = 6 },
            new { id = 3, title = "Trumpet", operator_id = 4, operator_name = "David", duration = 3 },
            new { id = 4, title = "Cello", operator_id = 5, operator_name = "Eve", duration = 7 },
            new { id = 5, title = "Piano", operator_id = 6, operator_name = "Frank", duration = 5 },
            new { id = 6, title = "Clarinet", operator_id = 7, operator_name = "Grace", duration = 4 },
            new { id = 7, title = "Cello", operator_id = 5, operator_name = "Eve", duration = 7 },
            new { id = 8, title = "Piano", operator_id = 6, operator_name = "Frank", duration = 5 },
            new { id = 9, title = "Drums", operator_id = 1, operator_name = "Alice", duration = 5 },
            new { id = 10, title = "Violin", operator_id = 2, operator_name = "Bob", duration = 4 },
            new { id = 11, title = "Flute", operator_id = 3, operator_name = "Charlie", duration = 6 },
            new { id = 12, title = "Trumpet", operator_id = 4, operator_name = "David", duration = 3 },
        };
        var shotlistUpdate = new
        {
            type = "shotlist_update",
            data
        };
        responseMessage = JsonSerializer.Serialize(shotlistUpdate);
        responseBuffer = Encoding.UTF8.GetBytes(responseMessage);
        await webSocket.SendAsync(new ArraySegment<byte>(responseBuffer), WebSocketMessageType.Text, true,
            CancellationToken.None);
        
        responseMessage = """{"type": "operator_assign", "operator_id": 2}""";
        responseBuffer = Encoding.UTF8.GetBytes(responseMessage);
        await webSocket.SendAsync(new ArraySegment<byte>(responseBuffer), WebSocketMessageType.Text, true,
            CancellationToken.None);
        
        responseMessage = """
                          {
                            "type": "message_history",
                            "messages": [
                              {"sender": "Vision mixer", "message": "Hello, Bob!"},
                              {"sender": "Vision mixer", "message": "Are you ready to go?"},
                              {"sender": "You", "message": "Yes, I'm ready."},
                              {"sender": "Vision mixer", "message": "Great, let's start with the first shot."},
                              {"sender": "You", "message": "Copy that."},
                              {"sender": "Vision mixer", "message": "Switch to camera 2."},
                              {"sender": "You", "message": "Camera 2 is live."},
                              {"sender": "Vision mixer", "message": "Prepare for the next shot."},
                              {"sender": "You", "message": "Ready for the next shot."},
                              {"sender": "Vision mixer", "message": "Good job, keep it up."}
                            ]
                          }
                          """;
        responseBuffer = Encoding.UTF8.GetBytes(responseMessage);
        await webSocket.SendAsync(new ArraySegment<byte>(responseBuffer), WebSocketMessageType.Text, true,
            CancellationToken.None);

        Task.Run(() => EchoMessages(webSocket));
        
        while (webSocket.State == WebSocketState.Open)
        {
            try
            {
                responseMessage = $"{{\"type\": \"shotlist_jump\", \"currently_live\": {i % data.Length}}}";
                responseBuffer = Encoding.UTF8.GetBytes(responseMessage);
                await webSocket.SendAsync(new ArraySegment<byte>(responseBuffer), WebSocketMessageType.Text, true, CancellationToken.None);
                i++;
                Console.WriteLine(responseMessage);
                Thread.Sleep(3000);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
                break;
            }
        }

        webSocket.Dispose();
    }
    
    private static async Task EchoMessages(WebSocket webSocket)
    {
        byte[] buffer = new byte[1024];
        while (webSocket.State == WebSocketState.Open)
        {
            WebSocketReceiveResult result;
            try
            {
                result = await webSocket.ReceiveAsync(new ArraySegment<byte>(buffer), CancellationToken.None);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
                break;
            }

            if (result.MessageType == WebSocketMessageType.Close)
            {
                Console.WriteLine("WebSocket connection closed.");
                await webSocket.CloseAsync(WebSocketCloseStatus.NormalClosure, "Closing", CancellationToken.None);
                break;
            }

            string receivedMessage = Encoding.UTF8.GetString(buffer, 0, result.Count);
            Console.WriteLine($"Received: {receivedMessage}");
            
            var jsonDocument = JsonDocument.Parse(receivedMessage);
            var root = jsonDocument.RootElement;
            string response = "";
            if (root.GetProperty("type").GetString() == "chat_message")
            {
                var message = root.GetProperty("message");
                var modifiedMessage = new
                {
                    type = "chat_message",
                    message = new
                    {
                        sender = "Vision Mixer",
                        message = message.GetProperty("message").GetString()
                    }
                };

                response = JsonSerializer.Serialize(modifiedMessage);
            }

            byte[] responseBuffer = Encoding.UTF8.GetBytes(response);
            await webSocket.SendAsync(new ArraySegment<byte>(responseBuffer), WebSocketMessageType.Text, true, CancellationToken.None);
        }
    }

    public static void Main(string[] args)
    {
        string uri = "http://*:5000/";
        Task.Run(() => Start(uri));

        Console.WriteLine("Press Enter to stop the server...");
        Console.ReadLine();
    }
}
