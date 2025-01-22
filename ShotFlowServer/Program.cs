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

        byte[] buffer = new byte[1024];
        while (webSocket.State == WebSocketState.Open)
        {
            try
            {
                WebSocketReceiveResult result = await webSocket.ReceiveAsync(new ArraySegment<byte>(buffer), CancellationToken.None);

                // Check if the connection is closed
                if (result.MessageType == WebSocketMessageType.Close)
                {
                    Console.WriteLine("WebSocket connection closed.");
                    await webSocket.CloseAsync(WebSocketCloseStatus.NormalClosure, "Closing", CancellationToken.None);
                    break;
                }

                // Echo the message back to the client
                string receivedMessage = Encoding.UTF8.GetString(buffer, 0, result.Count);
                Console.WriteLine($"Received: {receivedMessage}");

                string responseMessage = $"Echo: {receivedMessage}";
                byte[] responseBuffer = Encoding.UTF8.GetBytes(responseMessage);
                await webSocket.SendAsync(new ArraySegment<byte>(responseBuffer), WebSocketMessageType.Text, true, CancellationToken.None);
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
