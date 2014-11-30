package com.guebot.task;

import android.app.ProgressDialog;
import android.content.Context;
import android.os.AsyncTask;
import android.util.Log;
import android.widget.ImageView;

public class EnviarTask extends AsyncTask<Void, Void, Void> {
	private ProgressDialog dialog;
	private ImageView imageView;
	private Context context;
	private int image;
	

	public EnviarTask(Context context, ImageView imageView, int image) {
		this.context = context;
		this.imageView = imageView;
		this.image = image;
		dialog = new ProgressDialog(context);
		dialog.setCancelable(false);
	}

	@Override
	protected Void doInBackground(Void... arg0) {
		try {
			int i = 0;
			while (i < 2) {
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
		dialog.show();
	};

	@Override
	protected void onPostExecute(final Void success) {
		imageView.setImageResource(image);
		dialog.dismiss();
	}

}