package com.guebot;

import android.app.Activity;
import android.opengl.Visibility;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;

import com.guebot.task.EnviarTask;

public class MainActivity extends Activity {

	ImageView imageView;
	Button buttonAbajo;
	Button buttonArriba;
	Button buttonAbrir;
	Button buttonCerrar;
	Button buttonCalibrar;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		imageView = (ImageView) this.findViewById(R.id.imageView);
		buttonAbajo = (Button) this.findViewById(R.id.button_abajo);
		buttonArriba = (Button) this.findViewById(R.id.button_arriba);
		buttonAbrir = (Button) this.findViewById(R.id.button_abrir);
		buttonCerrar = (Button) this.findViewById(R.id.button_cerrar);
		buttonCalibrar = (Button) this.findViewById(R.id.button_calibrar);

		buttonAbajo.setVisibility(View.GONE);
		buttonArriba.setVisibility(View.GONE);
		buttonAbrir.setVisibility(View.GONE);
		buttonCerrar.setVisibility(View.GONE);
		buttonCalibrar.setVisibility(View.VISIBLE);

		//
		buttonAbajo.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				new EnviarTask(MainActivity.this, imageView,
						R.drawable.ic_abajo).execute((Void) null);

			}
		});
		buttonArriba.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				new EnviarTask(MainActivity.this, imageView,
						R.drawable.ic_arriba).execute((Void) null);
			}
		});
		buttonAbrir.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				new EnviarTask(MainActivity.this, imageView,
						R.drawable.ic_agarro).execute((Void) null);
			}
		});
		buttonCerrar.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				new EnviarTask(MainActivity.this, imageView,
						R.drawable.ic_soltar).execute((Void) null);
			}
		});
		//
		buttonCalibrar.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				new EnviarTask(MainActivity.this, imageView,
						R.drawable.ic_calibrar).execute((Void) null);
				buttonAbajo.setVisibility(View.VISIBLE);
				buttonArriba.setVisibility(View.VISIBLE);
				buttonAbrir.setVisibility(View.VISIBLE);
				buttonCerrar.setVisibility(View.VISIBLE);
				buttonCalibrar.setVisibility(View.GONE);
			}
		});

	}

}
