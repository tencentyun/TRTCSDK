package com.tencent.liteav.liveroom.ui.anchor.music;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.tencent.liteav.liveroom.R;

import java.util.List;

/**
 * Module:   MusicListAdapter
 * <p>
 * Function: 音乐列表的 Adapter
 */
class MusicListAdapter extends BaseAdapter {
    private List<MusicEntity> mData;
    private LayoutInflater                   mInflater;

    MusicListAdapter(LayoutInflater inflater, List<MusicEntity> list) {
        mInflater = inflater;
        mData = list;
    }

    @Override
    public int getCount() {
        return mData.size();
    }

    @Override
    public Object getItem(int position) {
        return mData.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        ViewHolder holder;
        if (convertView == null) {
            convertView = mInflater.inflate(
                    R.layout.liveroom_item_music, null);
            holder = new ViewHolder();
            holder.name = (TextView) convertView.findViewById(R.id.music_tv_name);
            holder.duration = (TextView) convertView.findViewById(R.id.music_tv_duration);
//            holder.selected = (ImageView) convertView.findViewById(R.id.music_iv_selected);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }
        holder.name.setText(mData.get(position).title);
        holder.duration.setText(mData.get(position).durationStr);
//        holder.selected.setVisibility(mData.get(position).state == 1 ? View.VISIBLE : View.GONE);
        return convertView;
    }

    private static class ViewHolder {
//        ImageView selected;
        TextView name;
        TextView duration;
    }
}