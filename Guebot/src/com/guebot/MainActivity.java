package com.guebot;

import java.security.NoSuchAlgorithmException;

import botserver.client.message.structure.JSONmessage;

import android.app.Activity;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.Toast;

public class MainActivity extends Activity {

	View layoutIntro;
	View layoutApp;
	ImageView imageView;
	ImageView btnAbajo;
	ImageView btnArriba;
	ImageView btnAbrir;
	ImageView btnCerrar;

	boolean abierto;
	boolean arriba;
	
	ClientBotserver cliente;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.activity_main);
		layoutIntro = this.findViewById(R.id.layout_intro);
		layoutApp = this.findViewById(R.id.layout_app);
		imageView = (ImageView) this.findViewById(R.id.imageView_robot);
		btnAbajo = (ImageView) this.findViewById(R.id.btn_abajo);
		btnArriba = (ImageView) this.findViewById(R.id.btn_arriba);
		btnAbrir = (ImageView) this.findViewById(R.id.btn_abrir);
		btnCerrar = (ImageView) this.findViewById(R.id.btn_cerrar);
		
		 cliente = null;
			try {
				cliente = new ClientBotserver();
				Log.v("MainActivity", cliente.toString());
			} catch (NoSuchAlgorithmException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

		//
		btnAbajo.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				if (arriba) {
					enviar("BAJAR");
				}
			}
		});
		btnArriba.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				if (!arriba) {
					enviar("SUBIR");
				}
			}
		});
		btnAbrir.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				if (!abierto) {
					if (arriba) {
						Toast.makeText(getApplicationContext(),
								"No podemos Hacer Huevos Revueltos",
								Toast.LENGTH_LONG).show();
					} else {
						enviar("ABRIR");
					}

				}
			}
		});
		btnCerrar.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				if (abierto) {
					enviar("CERRAR");
				}
			}
		});
		//
		new IntroTask().execute((Void) null);
	}

	/**
	 * funcion que se llama para enviar una instruccion al servidor
	 * 
	 * @param instruccion
	 */
	public void enviar(String instruccion) {
		// aca deberia ir el socket de envio
		simulacionRespuestaSocket(instruccion);

	}

	public void simulacionRespuestaSocket(String instruccion) {
		if (instruccion.equals("BAJAR")) {
			cliente.getSocket().emit(ClientBotserver.MOVEMENT_CHANNEL, JSONmessage.messageMovement("Tokennn", "DOWN", ""));
			arriba = false;
		}
		if (instruccion.equals("SUBIR")) {
			cliente.getSocket().emit(ClientBotserver.MOVEMENT_CHANNEL, JSONmessage.messageMovement("Tokennn", "UP", ""));
			arriba = true;
		}
		if (instruccion.equals("ABRIR")) {
			cliente.getSocket().emit(ClientBotserver.MOVEMENT_CHANNEL, JSONmessage.messageMovement("Tokennn", "OPEN", ""));
			abierto = true;
		}
		if (instruccion.equals("CERRAR")) {
			cliente.getSocket().emit(ClientBotserver.MOVEMENT_CHANNEL, JSONmessage.messageMovement("Tokennn", "CLOSE", ""));
			abierto = false;
		}
		setImgCambio();
	}

	/**
	 * funcion que cambia las imagenes se debe llamar siempre que el socket
	 * cambia modificando las varibles abierto arriba
	 */
	public void setImgCambio() {
		if (arriba && abierto) {
			imageView.setImageResource(R.drawable.arriba_abierto);
			btnArriba.setImageResource(R.drawable.btn_arriba2);
			btnAbajo.setImageResource(R.drawable.btn_abajo);
			btnAbrir.setImageResource(R.drawable.btn_abrir2);
			btnCerrar.setImageResource(R.drawable.btn_cerrar);
		} else if (arriba && !abierto) {
			imageView.setImageResource(R.drawable.arriba_huevo);
			btnArriba.setImageResource(R.drawable.btn_arriba2);
			btnAbajo.setImageResource(R.drawable.btn_abajo);
			btnAbrir.setImageResource(R.drawable.btn_abrir);
			btnCerrar.setImageResource(R.drawable.btn_cerrar2);
		} else if (!arriba && abierto) {
			imageView.setImageResource(R.drawable.abajo_abierto);
			btnArriba.setImageResource(R.drawable.btn_arriba);
			btnAbajo.setImageResource(R.drawable.btn_abajo2);
			btnAbrir.setImageResource(R.drawable.btn_abrir2);
			btnCerrar.setImageResource(R.drawable.btn_cerrar);
		} else {
			imageView.setImageResource(R.drawable.abajo_cerrado);
			btnArriba.setImageResource(R.drawable.btn_arriba);
			btnAbajo.setImageResource(R.drawable.btn_abajo2);
			btnAbrir.setImageResource(R.drawable.btn_abrir);
			btnCerrar.setImageResource(R.drawable.btn_cerrar2);
		}

	}

	public class IntroTask extends AsyncTask<Void, Void, Void> {

		@Override
		protected Void doInBackground(Void... arg0) {
			try {
				// aca se verifica por primera vez en que estado esta el robot
				// y se cambian las variables boolean abierto , arriba
				// para el ejemplo se deja un ramdon para simular varios estados
				abierto = ((int) (Math.random() * 10)) > 5;
				arriba = ((int) (Math.random() * 10)) > 5;
				int i = 0;
				while (i < 3) {
					i++;
					Thread.sleep(1000);
				}
			} catch (Exception e) {
				Log.e("error", e.toString());
			}
			return null;
		}

		@Override
		protected void onPreExecute() {
			layoutIntro.setVisibility(View.VISIBLE);
			layoutApp.setVisibility(View.GONE);
		};

		@Override
		protected void onPostExecute(final Void success) {
			setImgCambio();
			layoutIntro.setVisibility(View.GONE);
			layoutApp.setVisibility(View.VISIBLE);

		}

	}

}
