using LuaInterface;
using System;
using System.Net;
using System.Net.Sockets;
using System.Threading;
using UnityEngine;
public class SocketManager{
	private static void assert(){
		Byte[] b = new Byte[1];
		b[1] = 1;
	}
	private class Queue{
		private int qb;
		private int qf;
		private Byte[][] buf;
		private int bufLen;
		public void init(int bufLen, int subLen){
			this.bufLen = bufLen;
			buf = new Byte[bufLen][];
			for (int i = 0; i < bufLen; ++i){
				buf[i] = new Byte[subLen];
			}
		}
		public Byte[] back(){
			if ((qb + 1) % bufLen == qf){
				return null;
			}
			return buf[qb];
		}
		public void push(){
			if ((qb + 1) % bufLen == qf){
				assert();
			}
			++qb;
			qb %= bufLen;
		}
		public Byte[] front(){
			if (qf == qb){
				return null;
			}
			return buf[qf];
		}
		public void pop(){
			if (qf == qb){
				assert();
			}
			++qf;
			qf %= bufLen;
		}
	};
	private static Queue qSend;
	private static Queue qRecv;
	private static Byte[] bufRecv = new Byte[65536*2];
	private static Byte[] bufRecv2 = new Byte[32768];
	private static int bufRecvLen;
	private static Byte[] bufSend = new Byte[256];
	public static Action onConnect;
	public static Action onDisconnect;
	public static Action<int> onRecv;
	private static Socket socket;
	private static int step;
	private static String ip;
	private static int port;
	private static Thread thread;
	private static bool isClosing;
	private static LuaTable recvTable;
	private static LuaTable sendTable;
	public static Byte[] getBufSend(){
		return bufSend;
	}
	private static double lastTimePush;
	public static void threadRun(){
		try{
			for (;;){
				if (null == thread){
					return;
				}
				Thread.Sleep(15);

				if (isClosing) {
					isClosing = false;
					closeSocket();
				}

				if (null == socket)
				{
					if (null == ip)
					{
						continue;
					}

					try{
						IPAddress[] address = Dns.GetHostAddresses("api.sdk.pyw.cn");

						if (address.Length > 0)
						{
							if (address[0].AddressFamily == AddressFamily.InterNetworkV6)
							{
								Debug.Log("AddressFamily.InterNetworkV6");
								socket = new Socket(AddressFamily.InterNetworkV6, SocketType.Stream, ProtocolType.Tcp);
							}
							else
							{
								Debug.Log("AddressFamily.InterNetwork");
								socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
							}
						}
						else
						{
							Debug.Log("address.Length=" + address.Length);
						}

					}catch(Exception e){

						Debug.Log("AddressFamily.InterNetwork"+e);
						socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
					}
                    


                    string tmpIp = ip;
					ip = null;
					try
					{
						socket.Connect(tmpIp, port);
						Debug.Log("SocketManager connect success " + tmpIp + " " + port);
						socket.Blocking = false;
						bufRecvLen = 0;
						while (null != qSend.front())
						{
							qSend.pop();
						}
						step = 1;
					}
					catch
					{
						Debug.Log("SocketManager connect fail " + tmpIp + " " + port);
						step = 3;
						socket = null;
						continue;
					}
				}
				SocketError err;
				int len = socket.Receive(bufRecv, bufRecvLen, bufRecv.Length - bufRecvLen, 0, out err);
				if (len < 0)
				{
					assert();
				}
				if (len == 0)
				{
					if (!socket.Connected)
					{
						Debug.Log("!socket.Connected");
						closeSocket();
						step = 3;
						continue;
					}
				}
				bufRecvLen += len;
				if (bufRecv.Length <= bufRecvLen)
				{
					closeSocket();
					step = 3;
					continue;
				}
				int bufRecvPos = 0;
				while (bufRecvPos + 2 < bufRecvLen)
				{
					int msgLen = bufRecv[bufRecvPos] + 256 * bufRecv[bufRecvPos + 1] + 1;
					if (bufRecvLen < bufRecvPos + 2 + msgLen)
					{
						break;
					}
					Byte[] back = qRecv.back();
					if (back == null) {
						closeSocket();
						step = 3;
						break;
					}
					for (int i = 0; i < 2 + msgLen; ++i)
					{
						back[i] = bufRecv[i + bufRecvPos];
					}
					qRecv.push();
					bufRecvPos += 2 + msgLen;

					/*double lastTimePushNew=GetTimeStamp();
					  if(0<lastTimePush){
					  Debug.Log(lastTimePushNew-lastTimePush);
					  }
					  lastTimePush=lastTimePushNew;*/

				}
				for (int i = bufRecvPos; i < bufRecvLen; ++i)
				{
					bufRecv[i - bufRecvPos] = bufRecv[i];
				}
				bufRecvLen -= bufRecvPos;
				for (;;)
				{
					Byte[] front = qSend.front();
					if (null == front)
					{
						break;
					}

					try
					{
						socket.Send(front, front[0] + 2, 0);
					}
					catch(Exception e) {
						Debug.LogError(e);
						closeSocket();
						step = 3;
						break;
					}

					qSend.pop();
				}
			}
		}
		catch (Exception e)
		{
			Debug.LogError(e);
		}
	}
	public static void init()
	{
		qSend = new Queue();
		qSend.init(64, bufSend.Length);
		qRecv = new Queue();
		qRecv.init(128, bufRecv2.Length);

		thread = new Thread(threadRun);
		thread.IsBackground = true;
		thread.Priority = System.Threading.ThreadPriority.Highest;
		thread.Start();
	}

	public static void setup(LuaTable recv) {
		recvTable = recv;
	}

	public static void destroy()
	{
		thread = null;
		closeSocket();
	}
	public static void connect(String ipT, int portT)
	{
		isClosing = true;
		if (0 < step)
		{
			assert();
		}
		port = portT;
		ip = ipT;
		Debug.Log("SocketManager connect begin " + ip + " " + port);
	}
	static void closeSocket()
	{
		if (null == socket)
		{
			return;
		}
		if (socket.Connected) {
			socket.Shutdown(SocketShutdown.Both);
		}        
		socket.Close();
		socket = null;
		step = 0;
	}

	public static void close()
	{
		isClosing = true;
		step = 0;
	}

	public static void send(int bufSendLen)
	{
		if (socket == null) return;
		Byte[] back = qSend.back();
		back[0] = (byte)(bufSendLen - 2);
		if (back[0] != bufSendLen - 2)
		{
			assert();
		}
		for (int i = 1; i < bufSendLen; ++i)
		{
			back[i] = bufSend[i];
		}
		qSend.push();
	}
	public static void update()
	{
		if (step < 1)
		{
		}
		else if (step == 1)
		{
			step = 2;
			while (null != qRecv.front())
			{
				qRecv.pop();
			}
			onConnect();
		}
		else if (step == 2)
		{

			var luaState = LuaClient.GetMainState();

			for (;;)
			{
				Byte[] front = qRecv.front();
				if (null == front)
				{
					break;
				}

				int msgLen = front[0] + 256 * front[1] + 1;
				int oldTop=luaState.LuaGetTop();
				luaState.Push(recvTable);
				for(int i=1;i<=msgLen;++i){
					luaState.LuaPushInteger(front[1+i]);
					luaState.LuaRawSetI(oldTop+1,i);
				}
				luaState.LuaSetTop(oldTop);
				qRecv.pop();
				try
				{
					onRecv(msgLen);
				}
				catch (Exception e)
				{
					Debug.LogError(e);
				}
			}
		}
		else if (step == 3) {
			step = 0;
			if (onDisconnect != null) onDisconnect();
		}
	}
}