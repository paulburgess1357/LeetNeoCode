package main

// Definition for singly-linked list
type ListNode struct {
	Val  int
	Next *ListNode
}

// Definition for a binary tree node
type TreeNode struct {
	Val   int
	Left  *TreeNode
	Right *TreeNode
}

// Definition for n-ary tree node
type Node struct {
	Val      int
	Children []*Node
}
