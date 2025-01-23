using System;
using System.Net;
using System.Net.WebSockets;
using System.Text;
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
        
        responseMessage = """
                          {
                                "type": "shotlist_update",
                                "data": [
                                    {
                                        "id": 0,
                                        "title": "Drums",
                                        "operator_id": 1,
                                        "operator_name": "Alice",
                                        "duration": 5
                                    },
                                    {
                                        "id": 1,
                                        "title": "Violin",
                                        "operator_id": 2,
                                        "operator_name": "Bob",
                                        "duration": 4
                                    },
                                    {
                                        "id": 2,
                                        "title": "Flute",
                                        "operator_id": 3,
                                        "operator_name": "Charlie",
                                        "duration": 6
                                    },
                                    {
                                        "id": 3,
                                        "title": "Trumpet",
                                        "operator_id": 4,
                                        "operator_name": "David",
                                        "duration": 3
                                    },
                                    {
                                        "id": 4,
                                        "title": "Cello",
                                        "operator_id": 5,
                                        "operator_name": "Eve",
                                        "duration": 7
                                    },
                                    {
                                        "id": 5,
                                        "title": "Piano",
                                        "operator_id": 6,
                                        "operator_name": "Frank",
                                        "duration": 5
                                    },
                                    {
                                        "id": 6,
                                        "title": "Clarinet",
                                        "operator_id": 7,
                                        "operator_name": "Grace",
                                        "duration": 4
                                    }
                                ]
                          }
                          """;
        responseBuffer = Encoding.UTF8.GetBytes(responseMessage);
        await webSocket.SendAsync(new ArraySegment<byte>(responseBuffer), WebSocketMessageType.Text, true,
            CancellationToken.None);
        
        while (webSocket.State == WebSocketState.Open)
        {
            try
            {
                responseMessage = $"{{\"type\": \"shotlist_jump\", \"currently_live\": {i % 7}}}";
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

    public static void Main(string[] args)
    {
        string uri = "http://localhost:5000/";
        Task.Run(() => Start(uri));

        Console.WriteLine("Press Enter to stop the server...");
        Console.ReadLine();
    }
}
