package com.tencent.liteav.meeting.ui.widget.page;

import android.graphics.PointF;
import android.graphics.Rect;
import android.support.annotation.IntDef;
import android.support.annotation.IntRange;
import android.support.v7.widget.LinearSmoothScroller;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.util.SparseArray;
import android.view.View;
import android.view.ViewGroup;

import static android.support.v7.widget.RecyclerView.SCROLL_STATE_IDLE;
import static android.view.View.MeasureSpec.EXACTLY;
import static com.tencent.liteav.meeting.ui.widget.page.PagerConfig.Loge;
import static com.tencent.liteav.meeting.ui.widget.page.PagerConfig.Logi;

public class MeetingPageLayoutManager extends RecyclerView.LayoutManager implements RecyclerView.SmoothScroller.ScrollVectorProvider {
    public static final  int    VERTICAL   = 0;           // 垂直滚动
    public static final  int    HORIZONTAL = 1;         // 水平滚动
    private static final String TAG        = MeetingPageLayoutManager.class.getName();

    @IntDef({VERTICAL, HORIZONTAL})
    public @interface OrientationType {
    }            // 滚动类型

    @OrientationType
    private int mOrientation;                       // 默认水平滚动

    private int mOffsetX = 0;                       // 水平滚动距离(偏移量)
    private int mOffsetY = 0;                       // 垂直滚动距离(偏移量)

    private int mRows;                              // 行数
    private int mColumns;                           // 列数
    private int mOnePageSize;                       // 一页的条目数量

    private SparseArray<Rect> mItemFrames;          // 条目的显示区域

    private int mItemWidth  = 0;                     // 条目宽度
    private int mItemHeight = 0;                    // 条目高度

    private int mWidthUsed  = 0;                     // 已经使用空间，用于测量View
    private int mHeightUsed = 0;                    // 已经使用空间，用于测量View

    private int mMaxScrollX;                        // 最大允许滑动的宽度
    private int mMaxScrollY;                        // 最大允许滑动的高度
    private int mScrollState = SCROLL_STATE_IDLE;   // 滚动状态

    private boolean mAllowContinuousScroll = true;  // 是否允许连续滚动

    private RecyclerView mRecyclerView;

    /**
     * 构造函数
     *
     * @param rows        行数
     * @param columns     列数
     * @param orientation 方向
     */
    public MeetingPageLayoutManager(@IntRange(from = 1, to = 100) int rows,
                                    @IntRange(from = 1, to = 100) int columns,
                                    @OrientationType int orientation) {
        mItemFrames = new SparseArray<>();
        mOrientation = orientation;
        mRows = rows;
        mColumns = columns;
        mOnePageSize = mRows * mColumns;
    }

    @Override
    public void onAttachedToWindow(RecyclerView view) {
        super.onAttachedToWindow(view);
        mRecyclerView = view;
    }

    //--- 处理布局 ----------------------------------------------------------------------------------

    /**
     * 布局子View
     *
     * @param recycler Recycler
     * @param state    State
     */
    @Override
    public void onLayoutChildren(RecyclerView.Recycler recycler, RecyclerView.State state) {
        Logi("Item onLayoutChildren");
        Logi("Item onLayoutChildren isPreLayout = " + state.isPreLayout());
        Logi("Item onLayoutChildren isMeasuring = " + state.isMeasuring());
        Loge("Item onLayoutChildren state = " + state);

        // 如果是 preLayout 则不重新布局
        if (state.isPreLayout() || getUsableWidth() == 0) {
            return;
        }

        // 这里应该增加一个 spansizelookup 实现复杂的布局，时间原因下次应进行优化
        if (getItemCount() == 0) {
            removeAndRecycleAllViews(recycler);
            // 页面变化回调
            setPageCount(0);
            setPageIndex(0, false);
            return;
        } else if (getItemCount() == 1) {
            detachAndScrapAttachedViews(recycler); // 移除所有View
            View scrap = recycler.getViewForPosition(0);
            measureChildWithMargins(scrap, 0, 0);
            addView(scrap);
            layoutDecorated(scrap,
                    0,
                    0,
                    getWidth(),
                    getHeight());
            if (mPageListener != null) {
                mPageListener.onItemVisible(0, 0);
            }
            return;
        } else if (getItemCount() == 2) {
            detachAndScrapAttachedViews(recycler); // 移除所有View
            View scrap = recycler.getViewForPosition(0);
            int heightUse = getUsableHeight() / 2;
            measureChildWithMargins(scrap, 0, heightUse);
            addView(scrap);
            layoutDecorated(scrap,
                    0,
                    0,
                    getWidth(),
                    heightUse);
            scrap = recycler.getViewForPosition(1);
            measureChildWithMargins(scrap, 0, heightUse);
            addView(scrap);
            layoutDecorated(scrap,
                    0,
                    heightUse,
                    getWidth(),
                    getHeight());
            if (mPageListener != null) {
                mPageListener.onItemVisible(0, 1);
            }
            return;
        } else {
            setPageCount(getTotalPageCount());
            setPageIndex(getPageIndexByOffset(), false);
        }

        // 计算页面数量
        int mPageCount = getItemCount() / mOnePageSize;
        if (getItemCount() % mOnePageSize != 0) {
            mPageCount++;
        }

        // 计算可以滚动的最大数值，并对滚动距离进行修正
        if (canScrollHorizontally()) {
            mMaxScrollX = (mPageCount - 1) * getUsableWidth();
            mMaxScrollY = 0;
            if (mOffsetX > mMaxScrollX) {
                mOffsetX = mMaxScrollX;
            }
        } else {
            mMaxScrollX = 0;
            mMaxScrollY = (mPageCount - 1) * getUsableHeight();
            if (mOffsetY > mMaxScrollY) {
                mOffsetY = mMaxScrollY;
            }
        }

        // 接口回调
        // setPageCount(mPageCount);
        // setPageIndex(mCurrentPageIndex, false);

        Logi("count = " + getItemCount());

        if (mItemWidth <= 0) {
            mItemWidth = getUsableWidth() / mColumns;
        }
        if (mItemHeight <= 0) {
            mItemHeight = getUsableHeight() / mRows;
        }

        mWidthUsed = getUsableWidth() - mItemWidth;
        mHeightUsed = getUsableHeight() - mItemHeight;

        // 预存储两页的View显示区域
        for (int i = 0; i < mOnePageSize * 2; i++) {
            getItemFrameByPosition(i);
        }

//        if (mOffsetX == 0 && mOffsetY == 0) {
//            // 预存储View
//            for (int i = 0; i < mOnePageSize; i++) {
//                if (i >= getItemCount()) break; // 防止数据过少时导致数组越界异常
//                View view = recycler.getViewForPosition(i);
//                addView(view);
//                measureChildWithMargins(view, mWidthUsed, mHeightUsed);
//            }
//        }

        // 回收和填充布局
        recycleAndFillItems(recycler, state, true);
    }

    /**
     * 布局结束
     *
     * @param state State
     */
    @Override
    public void onLayoutCompleted(RecyclerView.State state) {
        super.onLayoutCompleted(state);
        if (state.isPreLayout()) return;
        // 页面状态回调
        setPageCount(getTotalPageCount());
        setPageIndex(getPageIndexByOffset(), false);
    }

    /**
     * 回收和填充布局
     *
     * @param recycler Recycler
     * @param state    State
     * @param isStart  是否从头开始，用于控制View遍历方向，true 为从头到尾，false 为从尾到头
     */
    private void recycleAndFillItems(RecyclerView.Recycler recycler, RecyclerView.State state,
                                     boolean isStart) {
        if (state.isPreLayout()) {
            return;
        }

        Logi("mOffsetX = " + mOffsetX);
        Logi("mOffsetY = " + mOffsetY);

        // 计算显示区域区前后多存储一列或则一行
        Rect displayRect = new Rect(mOffsetX - mItemWidth, mOffsetY - mItemHeight,
                getUsableWidth() + mOffsetX + mItemWidth, getUsableHeight() + mOffsetY + mItemHeight);
        // 对显显示区域进行修正(计算当前显示区域和最大显示区域对交集)
        displayRect.intersect(0, 0, mMaxScrollX + getUsableWidth(), mMaxScrollY + getUsableHeight());
        Loge("displayRect = " + displayRect.toString());

        int startPos  = 0;                  // 获取第一个条目的Pos
        int pageIndex = getPageIndexByOffset();
        startPos = pageIndex * mOnePageSize;
        Logi("startPos = " + startPos);
        startPos = startPos - mOnePageSize * 2;
        if (startPos < 0) {
            startPos = 0;
        }
        int stopPos = startPos + mOnePageSize * 4;
        if (stopPos > getItemCount()) {
            stopPos = getItemCount();
        }

        Loge("startPos = " + startPos);
        Loge("stopPos = " + stopPos);

        detachAndScrapAttachedViews(recycler); // 移除所有View

        if (isStart) {
            for (int i = startPos; i < stopPos; i++) {
                addOrRemove(recycler, displayRect, i);
            }
        } else {
            for (int i = stopPos - 1; i >= startPos; i--) {
                addOrRemove(recycler, displayRect, i);
            }
        }
        Loge("child count = " + getChildCount());
        startPos = pageIndex * mOnePageSize;
        stopPos = startPos + mOnePageSize - 1;
        if (stopPos >= getItemCount()) {
            stopPos = getItemCount() - 1;
        }
        Loge("visible from " + startPos + " to " + stopPos);
        if (mPageListener != null) {
            mPageListener.onItemVisible(startPos, stopPos);
        }
    }

    /**
     * 添加或者移除条目
     *
     * @param recycler    RecyclerView
     * @param displayRect 显示区域
     * @param i           条目下标
     */
    private void addOrRemove(RecyclerView.Recycler recycler, Rect displayRect, int i) {
        View child = recycler.getViewForPosition(i);
        Rect rect  = getItemFrameByPosition(i);
        if (!Rect.intersects(displayRect, rect)) {
            removeAndRecycleView(child, recycler);   // 回收入暂存区
        } else {
            addView(child);
            measureChildWithMargins(child, mWidthUsed, mHeightUsed);
            RecyclerView.LayoutParams lp = (RecyclerView.LayoutParams) child.getLayoutParams();
            layoutDecorated(child,
                    rect.left - mOffsetX + lp.leftMargin + getPaddingLeft(),
                    rect.top - mOffsetY + lp.topMargin + getPaddingTop(),
                    rect.right - mOffsetX - lp.rightMargin + getPaddingLeft(),
                    rect.bottom - mOffsetY - lp.bottomMargin + getPaddingTop());
        }
    }


    //--- 处理滚动 ----------------------------------------------------------------------------------

    /**
     * 水平滚动
     *
     * @param dx       滚动距离
     * @param recycler 回收器
     * @param state    滚动状态
     * @return 实际滚动距离
     */
    @Override
    public int scrollHorizontallyBy(int dx, RecyclerView.Recycler recycler, RecyclerView.State
            state) {
        int newX   = mOffsetX + dx;
        int result = dx;
        if (newX > mMaxScrollX) {
            result = mMaxScrollX - mOffsetX;
        } else if (newX < 0) {
            result = 0 - mOffsetX;
        }
        mOffsetX += result;
        setPageIndex(getPageIndexByOffset(), true);
        offsetChildrenHorizontal(-result);

        onLayoutChildren(recycler, state);
//        if (result > 0) {
//            recycleAndFillItems(recycler, state, true);
//        } else {
//            recycleAndFillItems(recycler, state, false);
//        }
        return result;
    }

    /**
     * 垂直滚动
     *
     * @param dy       滚动距离
     * @param recycler 回收器
     * @param state    滚动状态
     * @return 实际滚动距离
     */
    @Override
    public int scrollVerticallyBy(int dy, RecyclerView.Recycler recycler, RecyclerView.State
            state) {
        int newY   = mOffsetY + dy;
        int result = dy;
        if (newY > mMaxScrollY) {
            result = mMaxScrollY - mOffsetY;
        } else if (newY < 0) {
            result = 0 - mOffsetY;
        }
        mOffsetY += result;
        setPageIndex(getPageIndexByOffset(), true);
        offsetChildrenVertical(-result);
        if (result > 0) {
            recycleAndFillItems(recycler, state, true);
        } else {
            recycleAndFillItems(recycler, state, false);
        }
        return result;
    }

    /**
     * 监听滚动状态，滚动结束后通知当前选中的页面
     *
     * @param state 滚动状态
     */
    @Override
    public void onScrollStateChanged(int state) {
        Logi("onScrollStateChanged = " + state);
        mScrollState = state;
        super.onScrollStateChanged(state);
        if (state == SCROLL_STATE_IDLE) {
            setPageIndex(getPageIndexByOffset(), false);
        }
    }


    //--- 私有方法 ----------------------------------------------------------------------------------

    /**
     * 获取条目显示区域
     *
     * @param pos 位置下标
     * @return 显示区域
     */
    private Rect getItemFrameByPosition(int pos) {
        Rect rect = mItemFrames.get(pos);
        if (null == rect) {
            rect = new Rect();
            // 计算显示区域 Rect

            // 1. 获取当前View所在页数
            int page = pos / mOnePageSize;

            // 2. 计算当前页数左上角的总偏移量
            int offsetX = 0;
            int offsetY = 0;
            if (canScrollHorizontally()) {
                offsetX += getUsableWidth() * page;
            } else {
                offsetY += getUsableHeight() * page;
            }

            // 3. 根据在当前页面中的位置确定具体偏移量
            int pagePos = pos % mOnePageSize;       // 在当前页面中是第几个
            int row     = pagePos / mColumns;           // 获取所在行
            int col     = pagePos - (row * mColumns);   // 获取所在列

            offsetX += col * mItemWidth;
            offsetY += row * mItemHeight;

            // 状态输出，用于调试
            Logi("pagePos = " + pagePos);
            Logi("行 = " + row);
            Logi("列 = " + col);

            Logi("offsetX = " + offsetX);
            Logi("offsetY = " + offsetY);

            rect.left = offsetX;
            rect.top = offsetY;
            rect.right = offsetX + mItemWidth;
            rect.bottom = offsetY + mItemHeight;

            // 存储
            mItemFrames.put(pos, rect);
        }
        return rect;
    }

    /**
     * 获取可用的宽度
     *
     * @return 宽度 - padding
     */
    private int getUsableWidth() {
        return getWidth() - getPaddingLeft() - getPaddingRight();
    }

    /**
     * 获取可用的高度
     *
     * @return 高度 - padding
     */
    private int getUsableHeight() {
        return getHeight() - getPaddingTop() - getPaddingBottom();
    }


    //--- 页面相关(私有) -----------------------------------------------------------------------------

    /**
     * 获取总页数
     */
    private int getTotalPageCount() {
        if (getItemCount() <= 0) return 0;
        int totalCount = getItemCount() / mOnePageSize;
        if (getItemCount() % mOnePageSize != 0) {
            totalCount++;
        }
        return totalCount;
    }

    /**
     * 根据pos，获取该View所在的页面
     *
     * @param pos position
     * @return 页面的页码
     */
    private int getPageIndexByPos(int pos) {
        return pos / mOnePageSize;
    }

    /**
     * 根据 offset 获取页面Index
     *
     * @return 页面 Index
     */
    private int getPageIndexByOffset() {
        int pageIndex;
        if (canScrollVertically()) {
            int pageHeight = getUsableHeight();
            if (mOffsetY <= 0 || pageHeight <= 0) {
                pageIndex = 0;
            } else {
                pageIndex = mOffsetY / pageHeight;
                if (mOffsetY % pageHeight > pageHeight / 2) {
                    pageIndex++;
                }
            }
        } else {
            int pageWidth = getUsableWidth();
            if (mOffsetX <= 0 || pageWidth <= 0) {
                pageIndex = 0;
            } else {
                pageIndex = mOffsetX / pageWidth;
                if (mOffsetX % pageWidth > pageWidth / 2) {
                    pageIndex++;
                }
            }
        }
        Logi("getPageIndexByOffset pageIndex = " + pageIndex);
        return pageIndex;
    }


    //--- 公开方法 ----------------------------------------------------------------------------------

    /**
     * 创建默认布局参数
     *
     * @return 默认布局参数
     */
    @Override
    public RecyclerView.LayoutParams generateDefaultLayoutParams() {
        return new RecyclerView.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT);
    }

    /**
     * 处理测量逻辑
     *
     * @param recycler          RecyclerView
     * @param state             状态
     * @param widthMeasureSpec  宽度属性
     * @param heightMeasureSpec 高估属性
     */
    @Override
    public void onMeasure(RecyclerView.Recycler recycler, RecyclerView.State state, int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(recycler, state, widthMeasureSpec, heightMeasureSpec);
        int widthsize = View.MeasureSpec.getSize(widthMeasureSpec);      //取出宽度的确切数值
        int widthmode = View.MeasureSpec.getMode(widthMeasureSpec);      //取出宽度的测量模式

        int heightsize = View.MeasureSpec.getSize(heightMeasureSpec);    //取出高度的确切数值
        int heightmode = View.MeasureSpec.getMode(heightMeasureSpec);    //取出高度的测量模式

        // 将 wrap_content 转换为 match_parent
        if (widthmode != EXACTLY && widthsize > 0) {
            widthmode = EXACTLY;
        }
        if (heightmode != EXACTLY && heightsize > 0) {
            heightmode = EXACTLY;
        }
        setMeasuredDimension(View.MeasureSpec.makeMeasureSpec(widthsize, widthmode),
                View.MeasureSpec.makeMeasureSpec(heightsize, heightmode));
    }

    /**
     * 是否可以水平滚动
     *
     * @return true 是，false 不是。
     */
    @Override
    public boolean canScrollHorizontally() {
        return mOrientation == HORIZONTAL;
    }

    /**
     * 是否可以垂直滚动
     *
     * @return true 是，false 不是。
     */
    @Override
    public boolean canScrollVertically() {
        return mOrientation == VERTICAL;
    }

    /**
     * 找到下一页第一个条目的位置
     *
     * @return 第一个搞条目的位置
     */
    int findNextPageFirstPos() {
        int page = mLastPageIndex;
        page++;
        if (page >= getTotalPageCount()) {
            page = getTotalPageCount() - 1;
        }
        Loge("computeScrollVectorForPosition next = " + page);
        return page * mOnePageSize;
    }

    /**
     * 找到上一页的第一个条目的位置
     *
     * @return 第一个条目的位置
     */
    int findPrePageFirstPos() {
        // 在获取时由于前一页的View预加载出来了，所以获取到的直接就是前一页
        int page = mLastPageIndex;
        page--;
        Loge("computeScrollVectorForPosition pre = " + page);
        if (page < 0) {
            page = 0;
        }
        Loge("computeScrollVectorForPosition pre = " + page);
        return page * mOnePageSize;
    }

    /**
     * 获取当前 X 轴偏移量
     *
     * @return X 轴偏移量
     */
    public int getOffsetX() {
        return mOffsetX;
    }

    /**
     * 获取当前 Y 轴偏移量
     *
     * @return Y 轴偏移量
     */
    public int getOffsetY() {
        return mOffsetY;
    }


    //--- 页面对齐 ----------------------------------------------------------------------------------

    /**
     * 计算到目标位置需要滚动的距离{@link RecyclerView.SmoothScroller.ScrollVectorProvider}
     *
     * @param targetPosition 目标控件
     * @return 需要滚动的距离
     */
    @Override
    public PointF computeScrollVectorForPosition(int targetPosition) {
        PointF vector = new PointF();
        int[]  pos    = getSnapOffset(targetPosition);
        vector.x = pos[0];
        vector.y = pos[1];
        return vector;
    }

    /**
     * 获取偏移量(为PagerGridSnapHelper准备)
     * 用于分页滚动，确定需要滚动的距离。
     *
     * @param targetPosition 条目下标
     */
    int[] getSnapOffset(int targetPosition) {
        int[] offset = new int[2];
        int[] pos    = getPageLeftTopByPosition(targetPosition);
        offset[0] = pos[0] - mOffsetX;
        offset[1] = pos[1] - mOffsetY;
        return offset;
    }

    /**
     * 根据条目下标获取该条目所在页面的左上角位置
     *
     * @param pos 条目下标
     * @return 左上角位置
     */
    private int[] getPageLeftTopByPosition(int pos) {
        int[] leftTop = new int[2];
        int   page    = getPageIndexByPos(pos);
        if (canScrollHorizontally()) {
            leftTop[0] = page * getUsableWidth();
            leftTop[1] = 0;
        } else {
            leftTop[0] = 0;
            leftTop[1] = page * getUsableHeight();
        }
        return leftTop;
    }

    /**
     * 获取需要对齐的View
     *
     * @return 需要对齐的View
     */
    public View findSnapView() {
        if (null != getFocusedChild()) {
            return getFocusedChild();
        }
        if (getChildCount() <= 0) {
            return null;
        }
        int targetPos = getPageIndexByOffset() * mOnePageSize;   // 目标Pos
        for (int i = 0; i < getChildCount(); i++) {
            int childPos = getPosition(getChildAt(i));
            if (childPos == targetPos) {
                return getChildAt(i);
            }
        }
        return getChildAt(0);
    }


    //--- 处理页码变化 -------------------------------------------------------------------------------

    private boolean mChangeSelectInScrolling = true;    // 是否在滚动过程中对页面变化回调
    private int     mLastPageCount           = -1;                    // 上次页面总数
    private int     mLastPageIndex           = -1;                    // 上次页面下标

    /**
     * 设置页面总数
     *
     * @param pageCount 页面总数
     */
    private void setPageCount(int pageCount) {
        if (pageCount >= 0) {
            if (mPageListener != null && pageCount != mLastPageCount) {
                mPageListener.onPageSizeChanged(pageCount);
            }
            mLastPageCount = pageCount;
        }
    }

    /**
     * 设置当前选中页面
     *
     * @param pageIndex   页面下标
     * @param isScrolling 是否处于滚动状态
     */
    private void setPageIndex(int pageIndex, boolean isScrolling) {
        Loge("setPageIndex = " + pageIndex + ":" + isScrolling);
        if (pageIndex == mLastPageIndex) return;
        // 如果允许连续滚动，那么在滚动过程中就会更新页码记录
        if (isAllowContinuousScroll()) {
            mLastPageIndex = pageIndex;
        } else {
            // 否则，只有等滚动停下时才会更新页码记录
            if (!isScrolling) {
                mLastPageIndex = pageIndex;
            }
        }
        if (isScrolling && !mChangeSelectInScrolling) return;
        if (pageIndex >= 0) {
            if (null != mPageListener) {
                mPageListener.onPageSelect(pageIndex);
            }
        }
    }

    /**
     * 设置是否在滚动状态更新选中页码
     *
     * @param changeSelectInScrolling true：更新、false：不更新
     */
    public void setChangeSelectInScrolling(boolean changeSelectInScrolling) {
        mChangeSelectInScrolling = changeSelectInScrolling;
    }

    /**
     * 设置滚动方向
     *
     * @param orientation 滚动方向
     * @return 最终的滚动方向
     */
    @OrientationType
    public int setOrientationType(@OrientationType int orientation) {
        if (mOrientation == orientation || mScrollState != SCROLL_STATE_IDLE) return mOrientation;
        mOrientation = orientation;
        mItemFrames.clear();
        int x = mOffsetX;
        int y = mOffsetY;
        mOffsetX = y / getUsableHeight() * getUsableWidth();
        mOffsetY = x / getUsableWidth() * getUsableHeight();
        int mx = mMaxScrollX;
        int my = mMaxScrollY;
        mMaxScrollX = my / getUsableHeight() * getUsableWidth();
        mMaxScrollY = mx / getUsableWidth() * getUsableHeight();
        return mOrientation;
    }

    //--- 滚动到指定位置 -----------------------------------------------------------------------------

    @Override
    public void smoothScrollToPosition(RecyclerView recyclerView, RecyclerView.State state, int position) {
        int targetPageIndex = getPageIndexByPos(position);
        smoothScrollToPage(targetPageIndex);
    }

    /**
     * 平滑滚动到上一页
     */
    public void smoothPrePage() {
        smoothScrollToPage(getPageIndexByOffset() - 1);
    }

    /**
     * 平滑滚动到下一页
     */
    public void smoothNextPage() {
        smoothScrollToPage(getPageIndexByOffset() + 1);
    }

    /**
     * 平滑滚动到指定页面
     *
     * @param pageIndex 页面下标
     */
    public void smoothScrollToPage(int pageIndex) {
        if (pageIndex < 0 || pageIndex >= mLastPageCount) {
            Log.e(TAG, "pageIndex is outOfIndex, must in [0, " + mLastPageCount + ").");
            return;
        }
        if (null == mRecyclerView) {
            Log.e(TAG, "RecyclerView Not Found!");
            return;
        }

        // 如果滚动到页面之间距离过大，先直接滚动到目标页面到临近页面，在使用 smoothScroll 最终滚动到目标
        // 否则在滚动距离很大时，会导致滚动耗费的时间非常长
        int currentPageIndex = getPageIndexByOffset();
        if (Math.abs(pageIndex - currentPageIndex) > 3) {
            if (pageIndex > currentPageIndex) {
                scrollToPage(pageIndex - 3);
            } else if (pageIndex < currentPageIndex) {
                scrollToPage(pageIndex + 3);
            }
        }

        // 具体执行滚动
        LinearSmoothScroller smoothScroller = new PagerGridSmoothScroller(mRecyclerView);
        int                  position       = pageIndex * mOnePageSize;
        smoothScroller.setTargetPosition(position);
        startSmoothScroll(smoothScroller);
    }

    //=== 直接滚动 ===

    @Override
    public void scrollToPosition(int position) {
        int pageIndex = getPageIndexByPos(position);
        scrollToPage(pageIndex);
    }

    /**
     * 上一页
     */
    public void prePage() {
        scrollToPage(getPageIndexByOffset() - 1);
    }

    /**
     * 下一页
     */
    public void nextPage() {
        scrollToPage(getPageIndexByOffset() + 1);
    }

    /**
     * 滚动到指定页面
     *
     * @param pageIndex 页面下标
     */
    public void scrollToPage(int pageIndex) {
        if (pageIndex < 0 || pageIndex >= mLastPageCount) {
            Log.e(TAG, "pageIndex = " + pageIndex + " is out of bounds, mast in [0, " + mLastPageCount + ")");
            return;
        }

        if (null == mRecyclerView) {
            Log.e(TAG, "RecyclerView Not Found!");
            return;
        }

        int mTargetOffsetXBy = 0;
        int mTargetOffsetYBy = 0;
        if (canScrollVertically()) {
            mTargetOffsetXBy = 0;
            mTargetOffsetYBy = pageIndex * getUsableHeight() - mOffsetY;
        } else {
            mTargetOffsetXBy = pageIndex * getUsableWidth() - mOffsetX;
            mTargetOffsetYBy = 0;
        }
        Loge("mTargetOffsetXBy = " + mTargetOffsetXBy);
        Loge("mTargetOffsetYBy = " + mTargetOffsetYBy);
        mRecyclerView.scrollBy(mTargetOffsetXBy, mTargetOffsetYBy);
        setPageIndex(pageIndex, false);
    }

    /**
     * 是否允许连续滚动，默认为允许
     *
     * @return true 允许， false 不允许
     */
    public boolean isAllowContinuousScroll() {
        return mAllowContinuousScroll;
    }

    /**
     * 设置是否允许连续滚动
     *
     * @param allowContinuousScroll true 允许，false 不允许
     */
    public void setAllowContinuousScroll(boolean allowContinuousScroll) {
        mAllowContinuousScroll = allowContinuousScroll;
    }

    //--- 对外接口 ----------------------------------------------------------------------------------

    private PageListener mPageListener = null;

    public void setPageListener(PageListener pageListener) {
        mPageListener = pageListener;
    }

    public interface PageListener {
        /**
         * 页面总数量变化
         *
         * @param pageSize 页面总数
         */
        void onPageSizeChanged(int pageSize);

        /**
         * 页面被选中
         *
         * @param pageIndex 选中的页面
         */
        void onPageSelect(int pageIndex);

        void onItemVisible(int fromItem, int toItem);
    }
}
