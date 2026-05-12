package com.ocai.app;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {

    private EditText etSearch;
    private View btnSearch;
    private LinearLayout layoutLoading;
    private TextView tvStatus;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        etSearch      = findViewById(R.id.etSearch);
        btnSearch     = findViewById(R.id.btnSearch);
        layoutLoading = findViewById(R.id.layoutLoading);
        tvStatus      = findViewById(R.id.tvStatus);

        btnSearch.setOnClickListener(v -> doSearch());

        // Trigger search on keyboard Enter key
        etSearch.setOnEditorActionListener((v, actionId, event) -> {
            if (actionId == EditorInfo.IME_ACTION_SEARCH) {
                doSearch();
                return true;
            }
            return false;
        });
    }

    private void doSearch() {
        String input = etSearch.getText().toString().trim();
        if (input.isEmpty()) {
            etSearch.setError("Введите запрос");
            return;
        }

        // Hide soft keyboard
        InputMethodManager imm = (InputMethodManager) getSystemService(INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(etSearch.getWindowToken(), 0);

        setLoading(true, "Ищу товары...");

        DeepSeekService.extractKeywords(input, new DeepSeekService.Callback() {
            @Override
            public void onSuccess(String keywords) {
                runOnUiThread(() -> {
                    setLoading(false, "");
                    openUrl(Config.OCAI_SEARCH + encode(keywords), keywords);
                });
            }

            @Override
            public void onError(String fallback) {
                runOnUiThread(() -> {
                    setLoading(false, "");
                    // AI failed, search with raw input as fallback
                    openUrl(Config.OCAI_SEARCH + encode(fallback), fallback);
                });
            }
        });
    }

    private void openUrl(String url, String title) {
        Intent intent = new Intent(this, WebViewActivity.class);
        intent.putExtra("url", url);
        intent.putExtra("title", title);
        startActivity(intent);
    }

    private void setLoading(boolean loading, String status) {
        btnSearch.setEnabled(!loading);
        layoutLoading.setVisibility(loading ? View.VISIBLE : View.GONE);
        tvStatus.setText(status);
    }

    private String encode(String text) {
        try {
            return java.net.URLEncoder.encode(text, "UTF-8");
        } catch (Exception e) {
            return text;
        }
    }
}
